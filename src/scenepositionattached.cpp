/*
 *  SPDX-FileCopyrightText: 2017 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#include "scenepositionattached.h"
#include <QDebug>
#include <QQuickItem>

ScenePositionAttached::ScenePositionAttached(QObject *parent)
    : QObject(parent)
    , m_cachedX(0)
    , m_cachedY(0)
    , m_cachedXValid(false)
    , m_cachedYValid(false)
{
    m_item = qobject_cast<QQuickItem *>(parent);
    connectAncestors(m_item);
}

ScenePositionAttached::~ScenePositionAttached()
{
}

qreal ScenePositionAttached::x() const
{
    if (!m_cachedXValid) {
        qreal x = 0.0;
        QQuickItem *item = m_item;

        while (item) {
            x += item->x();
            item = item->parentItem();
        }

        m_cachedX = x;
        m_cachedXValid = true;
    }
    return m_cachedX;
}

qreal ScenePositionAttached::y() const
{
    if (!m_cachedYValid) {
        qreal y = 0.0;
        QQuickItem *item = m_item;

        while (item) {
            y += item->y();
            item = item->parentItem();
        }

        m_cachedY = y;
        m_cachedYValid = true;
    }
    return m_cachedY;
}

void ScenePositionAttached::slotXChanged()
{
    m_cachedXValid = false;
    Q_EMIT xChanged();
}

void ScenePositionAttached::slotYChanged()
{
    m_cachedYValid = false;
    Q_EMIT yChanged();
}

void ScenePositionAttached::connectAncestors(QQuickItem *item)
{
    if (!item) {
        return;
    }

    QQuickItem *ancestor = item;
    while (ancestor) {
        m_ancestors << ancestor;

        connect(ancestor, &QQuickItem::xChanged, this, &ScenePositionAttached::slotXChanged);
        connect(ancestor, &QQuickItem::yChanged, this, &ScenePositionAttached::slotYChanged);
        connect(ancestor, &QQuickItem::parentChanged, this, [this, ancestor]() {
            m_cachedXValid = false;
            m_cachedYValid = false;
            do {
                disconnect(ancestor, nullptr, this, nullptr);
                m_ancestors.pop_back();
            } while (!m_ancestors.isEmpty() && m_ancestors.last() != ancestor);

            connectAncestors(ancestor);
            Q_EMIT xChanged();
            Q_EMIT yChanged();
        });

        ancestor = ancestor->parentItem();
    }
}

ScenePositionAttached *ScenePositionAttached::qmlAttachedProperties(QObject *object)
{
    return new ScenePositionAttached(object);
}

#include "moc_scenepositionattached.cpp"
