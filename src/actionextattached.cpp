/*
 *  SPDX-FileCopyrightText: 2023 ivan tkachenko <me@ratijas.tk>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#include "actionextattached.h"

#include "loggingcategory.h"

#include <QQmlComponent>
#include <QQmlContext>

struct KirigamiActionCompatWrapper {
    KirigamiActionCompatWrapper(QObject *action)
        : action(action)
    {
        Q_ASSERT(action);
    }

    bool isVisible() const;
    void setVisible(bool);

private:
    QObject *action;
};

bool KirigamiActionCompatWrapper::isVisible() const
{
    return action->property("visible").toBool();
}

void KirigamiActionCompatWrapper::setVisible(bool visible)
{
    action->setProperty("visible", QVariant::fromValue(visible));
}

ActionExtAttached::ActionExtAttached(QObject *parent)
    : QObject(parent)
    , m_visible(true)
    , m_separator(false)
    , m_expandible(false)
    , m_displayHints(DisplayHint::DisplayHint::NoPreference)
    , m_displayComponent(nullptr)
    , m_parentActionExt(nullptr)
    , m_children({})
{
    Q_ASSERT(parent);
    if (!isQQC2Action(parent)) {
        qCWarning(KirigamiLog) << "ActionExt must be attached to a QtQuick.Controls/Action";
        return;
    } else if (isKirigamiAction(parent)) {
        // compat bindings, because aliases can't point to attached objects
        bindKirigamiActionParent();
    }
}

ActionExtAttached::~ActionExtAttached()
{
    // TODO: clean up parent/children
}

bool ActionExtAttached::isVisible() const
{
    return m_visible;
}

void ActionExtAttached::setVisible(bool visible)
{
    if (m_visible == visible) {
        return;
    }

    m_visible = visible;
    if (isKirigamiAction(parent())) {
        KirigamiActionCompatWrapper(parent()).setVisible(visible);
    }
    Q_EMIT visibleChanged();
}

ActionExtAttached *ActionExtAttached::qmlAttachedProperties(QObject *object)
{
    return new ActionExtAttached(object);
}

void ActionExtAttached::syncVisible()
{
    Q_ASSERT(isKirigamiAction(parent()));
    setVisible(KirigamiActionCompatWrapper(parent()).isVisible());
}

bool ActionExtAttached::isQQC2Action(const QObject *object)
{
    return object && object->inherits("QQuickAction");
}

static void printInheritanceChain(const QObject *o)
{
    if (!o) {
        qDebug() << "Called on null object!";
    }
    qDebug() << "Class hierarchy of" << o;
    const QMetaObject *mo = o->metaObject();
    do {
        qDebug() << "  " << mo->className();
        mo = mo->superClass();
    } while (mo);
}

bool ActionExtAttached::isKirigamiAction(const QObject *object)
{
    if (!object) {
        return false;
    }

    // TODO: store metaobject in a static hashmap per engine, remember to clean up when an engine is destroyed.
    // Further cache the results of both checks in a bitfield member flag, because type of attachee is constant.
    auto engine = qmlEngine(object);
    QQmlComponent component{engine};
    component.loadFromModule("org.kde.kirigami", "Action");
    auto o = component.create();
    const bool inherits = object->metaObject()->inherits(o->metaObject());
    delete o;

    return inherits;
}

void ActionExtAttached::bindKirigamiActionParent()
{
    connect(parent(), SIGNAL(visibleChanged()), this, SLOT(syncVisible()));
}

#include "moc_actionextattached.cpp"
