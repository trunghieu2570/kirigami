/*
 *  SPDX-FileCopyrightText: 2023 ivan tkachenko <me@ratijas.tk>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#include "actionhelper.h"
#include <QByteArray>
#include <QQmlComponent>
#include <QQmlEngine>
#include <QQmlInfo>
#include <algorithm>
#include <qqmllist.h>

ActionHelper::ActionHelper(QObject *parent)
    : QObject(parent)
{
}

ActionHelper::~ActionHelper() = default;

qsizetype ActionHelper::list_count(QQmlListProperty<QObject> *list)
{
    const auto helper = static_cast<ActionHelper *>(list->object);
    const auto children = helper->children();
    if (!children.isValid()) {
        return 0;
    }
    const auto count = children.count();
    qsizetype result = 0;
    for (auto i = 0; i < count; i++) {
        if (QObject *child = children.at(i); child && child->property("visible").toBool()) {
            result += 1;
        }
    }
    return result;
}

QObject *ActionHelper::list_at(QQmlListProperty<QObject> *list, qsizetype index)
{
    const auto helper = static_cast<ActionHelper *>(list->object);
    const auto children = helper->children();
    if (!children.isValid()) {
        return nullptr;
    }
    const auto count = children.count();
    qsizetype result = 0;
    for (auto i = 0; i < count; i++) {
        if (QObject *child = children.at(i); child && child->property("visible").toBool()) {
            if (result == index) {
                return child;
            }
            result += 1;
        }
    }
    return nullptr;
}

// QVariant ActionHelper::actionType() const
// {
//     return {};
// }

// void ActionHelper::setActionType(const QVariant &type)
// {
//     qDebug() << "MetaType:" << type << type.metaType();
//     // if (type.metaType() == QMetaType::QJSValue)
// }

QQmlListProperty<QObject> ActionHelper::visibleChildren()
{
    if (QObject *action = parent(); !action) {
        qDebug() << "queried visibleChildren without parent";
    } else {
        qDebug() << "queried visibleChildren";
    }
    return QQmlListProperty<QObject>(this, nullptr, list_count, list_at);
}

// ActionHelper *ActionHelper::qmlAttachedProperties(QObject *parent)
// {
//     return new ActionHelper(parent);
// }

// QObject *ActionHelper::action() const
// {
//     return parent();
// }

// void ActionHelper::setAction(QObject *action)
// {
//     qDebug() << "Parent:" << parent() << "action:" << action;
//     if (parent() || !action) {
//         return;
//     }
//     setParent(action);
//     qDebug() << "MetaType: " << action->metaObject()->metaType();
// }

QQmlListReference ActionHelper::children()
{
    if (QObject *action = parent()) {
        qDebug() << "queried children";
        return QQmlListReference(action, "children");
    } else {
        qDebug() << "queried children without parent";
        return QQmlListReference();
    }
}

void ActionHelper::classBegin()
{
    Q_ASSERT(parent());

    // const auto engine = qmlEngine(this);
    // Q_ASSERT(engine);
    // static QMap<QQmlEngine, QMetaType> actionTypes;

    // engine->
    // QQmlComponent actionComponent(engine, "org.kde.kirigami", "Action", nullptr);
    // actionComponent.ob

    qDebug() << "classBegin" << this << parent();
    if (parent()) {
        qDebug() << "MetaType: " << parent()->metaObject()->className();
    }
}

void ActionHelper::componentComplete()
{
    const auto action = parent();
    const auto mo = action->metaObject();
    const auto childrenIndex = mo->indexOfProperty("children");
    if (childrenIndex != -1) {
        const auto childrenProperty = mo->property(childrenIndex);
        Q_ASSERT(childrenProperty.isValid() && childrenProperty.metaType().flags() & QMetaType::IsQmlList && childrenProperty.hasNotifySignal());

        const auto updateSlot = metaObject()->method(metaObject()->indexOfSlot("updateChildren()"));
        Q_ASSERT(updateSlot.isValid());

        const auto ok = connect(action, childrenProperty.notifySignal(), this, updateSlot);
        Q_ASSERT(ok);
    }
    setUp();
}

void ActionHelper::updateChildren()
{
    qDebug() << "UPDATE";

    auto newChildren = collectChildren();
    newChildren.removeIf([](const auto &child) -> bool {
        return child == nullptr;
    });
    m_children.removeIf([](const auto &child) -> bool {
        return child.isNull();
    });

    QList<QObject *> removed;
    QList<QObject *> added;

    for (const auto &child : std::as_const(newChildren)) {
        if (!m_children.contains(child)) {
            added.append(child);
        }
    }
    for (const auto &child : std::as_const(m_children)) {
        if (!newChildren.contains(child)) {
            removed.append(child);
        }
    }

    if (added.isEmpty() && removed.isEmpty()) {
        return;
    }

    for (const auto child : std::as_const(removed)) {
        disconnect(child, SIGNAL(visibleChanged()), this, SIGNAL(visibleChildrenChanged()));
        if (child->property("parent").value<QObject *>() == parent()) {
            child->setProperty("parent", QVariant::fromValue(nullptr));
        }
    }

    for (const auto child : std::as_const(added)) {
        connect(child, SIGNAL(visibleChanged()), this, SIGNAL(visibleChildrenChanged()));
        child->setProperty("parent", QVariant::fromValue(parent()));
    }

    m_children.clear();
    m_children.reserve(newChildren.count());
    for (const auto child : newChildren) {
        m_children.append(child);
    }

    Q_EMIT visibleChildrenChanged();
}

void ActionHelper::setUp()
{
    auto list = children();
    if (!list.isValid()) {
        return;
    }

    updateChildren();
}

QList<QObject *> ActionHelper::collectChildren()
{
    const auto list = children();
    const auto count = list.count();
    QList<QObject *> result;
    result.reserve(count);

    for (qsizetype i = 0; i < count; i++) {
        result.append(list.at(i));
    }

    return result;
}
