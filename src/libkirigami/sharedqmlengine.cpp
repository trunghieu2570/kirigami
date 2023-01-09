/*
    SPDX-FileCopyrightText: 2013 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2023 Alexander Lohnau <alexander.lohnau@gmx.de>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

#include "sharedqmlengine.h"

#include <QDebug>
#include <QQmlContext>
#include <QQmlEngine>
#include <QQmlIncubator>
#include <QQmlNetworkAccessManagerFactory>
#include <QQuickItem>
#include <QTimer>

#include "loggingcategory.h"

namespace Kirigami
{
class QmlObjectIncubator : public QQmlIncubator
{
public:
    QVariantHash m_initialProperties;

protected:
    void setInitialState(QObject *object) override
    {
        QHashIterator<QString, QVariant> i(m_initialProperties);
        while (i.hasNext()) {
            i.next();
            object->setProperty(i.key().toLatin1().data(), i.value());
        }
    }
};

class QmlObjectPrivate
{
public:
    QmlObjectPrivate(QmlObject *parent)
        : q(parent)
        , component(nullptr)
        , delay(false)
        , m_engine(engine())
    {
        executionEndTimer = new QTimer(q);
        executionEndTimer->setInterval(0);
        executionEndTimer->setSingleShot(true);
        QObject::connect(executionEndTimer, &QTimer::timeout, q, [this]() {
            scheduleExecutionEnd();
        });
    }

    ~QmlObjectPrivate()
    {
        delete incubator.object();

        // Reset the static engine when we and the static ptr are the last objects holding references to it
        if (s_engine.use_count() == 2) {
            s_engine.reset();

            // QQmlEngine does not take ownership of the QNAM factory so we need to
            // make sure to clean it, but only if we are the last user of the engine
            // otherwise we risk resetting the factory on an engine that is still in
            // use.
            auto factory = engine()->networkAccessManagerFactory();
            engine()->setNetworkAccessManagerFactory(nullptr);
            delete factory;
        }
    }

    void errorPrint(QQmlComponent *component);
    void execute(const QUrl &source);
    void scheduleExecutionEnd();
    void minimumWidthChanged();
    void minimumHeightChanged();
    void maximumWidthChanged();
    void maximumHeightChanged();
    void preferredWidthChanged();
    void preferredHeightChanged();
    void checkInitializationCompleted();

    QmlObject *q;

    QUrl source;

    QmlObjectIncubator incubator;
    QQmlComponent *component;
    QTimer *executionEndTimer;
    QObject *context{nullptr};
    QQmlContext *rootContext;
    bool delay;
    std::shared_ptr<QQmlEngine> m_engine;

    static std::shared_ptr<QQmlEngine> engine()
    {
        if (!s_engine) {
            s_engine = std::make_shared<QQmlEngine>();
        }
        return s_engine;
    }

private:
    static std::shared_ptr<QQmlEngine> s_engine;
};

std::shared_ptr<QQmlEngine> QmlObjectPrivate::s_engine = std::shared_ptr<QQmlEngine>{};

void QmlObjectPrivate::errorPrint(QQmlComponent *component)
{
    QString errorStr = QStringLiteral("Error loading QML file.\n");
    if (component->isError()) {
        const QList<QQmlError> errors = component->errors();
        for (const QQmlError &error : errors) {
            errorStr +=
                (error.line() > 0 ? QString(QString::number(error.line()) + QLatin1String(": ")) : QLatin1String("")) + error.description() + QLatin1Char('\n');
        }
    }
    qWarning(KirigamiLog) << component->url().toString() << '\n' << errorStr;
}

void QmlObjectPrivate::execute(const QUrl &source)
{
    if (source.isEmpty()) {
        qWarning(KirigamiLog) << "File name empty!";
        return;
    }

    delete component;
    component = new QQmlComponent(engine().get(), q);
    QObject::connect(component, &QQmlComponent::statusChanged, q, &QmlObject::statusChanged, Qt::QueuedConnection);
    delete incubator.object();

    component->loadUrl(source);

    if (delay) {
        executionEndTimer->start(0);
    } else {
        scheduleExecutionEnd();
    }
}

void QmlObjectPrivate::scheduleExecutionEnd()
{
    if (component->isReady() || component->isError()) {
        q->completeInitialization();
    } else {
        QObject::connect(component, &QQmlComponent::statusChanged, q, [this]() {
            q->completeInitialization();
        });
    }
}

/*static*/ std::shared_ptr<QQmlEngine> QmlObject::qmlEngineInternal()
{
    return QmlObjectPrivate::engine();
}

QmlObject::QmlObject(QObject *localizeContext, QQmlContext *rootContext, QObject *parent)
    : QObject(parent)
    , d(new QmlObjectPrivate(this))
{
    Q_ASSERT(rootContext);
    Q_ASSERT(localizeContext);

    d->context = localizeContext;
    d->rootContext = rootContext; // TODO Set parent?
    d->rootContext->setContextObject(d->context);
}

QmlObject::~QmlObject() = default;

void QmlObject::setTranslationDomain(const QString &translationDomain)
{
    d->context->setProperty("translationDomain", translationDomain);
}

QString QmlObject::translationDomain() const
{
    return d->context->property("translationDomain").toString();
}

void QmlObject::setSource(const QUrl &source)
{
    d->source = source;
    d->execute(source);
}

QUrl QmlObject::source() const
{
    return d->source;
}

void QmlObject::setInitializationDelayed(const bool delay)
{
    d->delay = delay;
}

bool QmlObject::isInitializationDelayed() const
{
    return d->delay;
}

std::shared_ptr<QQmlEngine> QmlObject::engine()
{
    return d->engine();
}

QObject *QmlObject::rootObject() const
{
    if (d->incubator.status() == QQmlIncubator::Loading) {
        qWarning(KirigamiLog) << "Trying to use rootObject before initialization is completed, whilst using setInitializationDelayed. Forcing completion";
        d->incubator.forceCompletion();
    }
    return d->incubator.object();
}

QQmlComponent *QmlObject::mainComponent() const
{
    return d->component;
}

QQmlContext *QmlObject::rootContext() const
{
    return d->rootContext;
}

QQmlComponent::Status QmlObject::status() const
{
    if (!d->engine()) {
        return QQmlComponent::Error;
    }

    if (!d->component) {
        return QQmlComponent::Null;
    }

    return QQmlComponent::Status(d->component->status());
}

void QmlObjectPrivate::checkInitializationCompleted()
{
    if (!incubator.isReady() && incubator.status() != QQmlIncubator::Error) {
        QTimer::singleShot(0, q, SLOT(checkInitializationCompleted()));
        return;
    }

    if (!incubator.object()) {
        errorPrint(component);
    }

    Q_EMIT q->finished();
}

void QmlObject::completeInitialization(const QVariantHash &initialProperties)
{
    d->executionEndTimer->stop();
    if (d->incubator.object()) {
        return;
    }

    if (!d->component) {
        qWarning(KirigamiLog) << "No component for" << source();
        return;
    }

    if (d->component->status() != QQmlComponent::Ready || d->component->isError()) {
        d->errorPrint(d->component);
        return;
    }

    d->incubator.m_initialProperties = initialProperties;
    d->component->create(d->incubator, d->rootContext);

    if (d->delay) {
        d->checkInitializationCompleted();
    } else {
        d->incubator.forceCompletion();

        if (!d->incubator.object()) {
            d->errorPrint(d->component);
        }
        Q_EMIT finished();
    }
}

QObject *QmlObject::createObjectFromSource(const QUrl &source, QQmlContext *context, const QVariantHash &initialProperties)
{
    QQmlComponent *component = new QQmlComponent(d->engine().get(), this);
    component->loadUrl(source);

    return createObjectFromComponent(component, context, initialProperties);
}

QObject *QmlObject::createObjectFromComponent(QQmlComponent *component, QQmlContext *context, const QVariantHash &initialProperties)
{
    QmlObjectIncubator incubator;
    incubator.m_initialProperties = initialProperties;
    component->create(incubator, context ? context : d->rootContext);
    incubator.forceCompletion();

    QObject *object = incubator.object();

    if (!component->isError() && object) {
        // memory management
        component->setParent(object);
        // reparent to root object if wasn't specified otherwise by initialProperties
        if (!initialProperties.contains(QLatin1String("parent"))) {
            if (qobject_cast<QQuickItem *>(rootObject())) {
                object->setProperty("parent", QVariant::fromValue(rootObject()));
            } else {
                object->setParent(rootObject());
            }
        }

        return object;

    } else {
        d->errorPrint(component);
        delete object;
        return nullptr;
    }
}

}

#include "moc_sharedqmlengine.cpp"
