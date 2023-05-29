/*
 *  SPDX-FileCopyrightText: 2017 Marco Martin <mart@kde.org>
 *  SPDX-FileCopyrightText: 2023 ivan tkachenko <me@ratijas.tk>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#include "scenepositionattached.h"
#include <QDebug>
#include <QQuickItem>

PositionCache::PositionCache()
    : x(0)
    , y(0)
    , xIsValid(false)
    , yIsValid(false)
{
}

template<typename F>
qreal PositionCache::getX(F updateX)
{
    if (!xIsValid) {
        x = updateX();
        xIsValid = true;
    }
    return x;
}

template<typename F>
qreal PositionCache::getY(F updateY)
{
    if (!yIsValid) {
        y = updateY();
        yIsValid = true;
    }
    return y;
}

void PositionCache::invalidate()
{
    invalidateX();
    invalidateY();
}

void PositionCache::invalidateX()
{
    xIsValid = false;
}

void PositionCache::invalidateY()
{
    yIsValid = false;
}

ScenePositionAttached::ScenePositionAttached(QObject *parent)
    : QObject(parent)
    , m_cache()
{
    m_item = qobject_cast<QQuickItem *>(parent);
    connectAncestors(m_item);
}

ScenePositionAttached::~ScenePositionAttached()
{
}

qreal ScenePositionAttached::x() const
{
    return m_cache.getX([this]() {
        qreal x = 0.0;
        QQuickItem *item = m_item;

        while (item) {
            x += item->x();
            item = item->parentItem();
        }

        return x;
    });
}

qreal ScenePositionAttached::y() const
{
    return m_cache.getY([this]() {
        qreal y = 0.0;
        QQuickItem *item = m_item;

        while (item) {
            y += item->y();
            item = item->parentItem();
        }

        return y;
    });
}

void ScenePositionAttached::slotXChanged()
{
    m_cache.invalidateX();
    Q_EMIT xChanged();
}

void ScenePositionAttached::slotYChanged()
{
    m_cache.invalidateY();
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
            m_cache.invalidate();

            while (!m_ancestors.isEmpty()) {
                QQuickItem *last = m_ancestors.takeLast();
                // Disconnect the item which had its parent changed too,
                // because connectAncestors() would reconnect it next.
                disconnect(last, nullptr, this, nullptr);
                if (last == ancestor) {
                    break;
                }
            }

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
