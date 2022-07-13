/*
 *  SPDX-FileCopyrightText: 2020 Carson Black <uhhadd@gmail.com>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#include <QQmlProperty>

#include "sizegroup.h"

#define pThis (static_cast<SizeGroup *>(prop->object))

void SizeGroup::appendItem(QQmlListProperty<QQuickItem> *prop, QQuickItem *value)
{
    pThis->m_items << value;
    pThis->connectItem(value);
}

#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
int SizeGroup::itemCount(QQmlListProperty<QQuickItem> *prop)
#else
qsizetype SizeGroup::itemCount(QQmlListProperty<QQuickItem> *prop)
#endif
{
    return pThis->m_items.count();
}

#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
QQuickItem *SizeGroup::itemAt(QQmlListProperty<QQuickItem> *prop, int index)
#else
QQuickItem *SizeGroup::itemAt(QQmlListProperty<QQuickItem> *prop, qsizetype index)
#endif
{
    return pThis->m_items[index];
}

void SizeGroup::clearItems(QQmlListProperty<QQuickItem> *prop)
{
    for (const auto &item : std::as_const(pThis->m_items)) {
        pThis->disconnectItem(item);
    }
    pThis->m_items.clear();
    pThis->adjustItems(Mode::Both);
}

void SizeGroup::connectItem(QQuickItem *item)
{
    auto conn1 = connect(item, &QQuickItem::implicitWidthChanged, this, [this]() {
        adjustItems(Mode::Width);
    });
    auto conn2 = connect(item, &QQuickItem::implicitHeightChanged, this, [this]() {
        adjustItems(Mode::Height);
    });
    m_connections[item] = qMakePair(conn1, conn2);
    adjustItems(m_mode);
}

void SizeGroup::disconnectItem(QQuickItem *item)
{
    if (item == nullptr) {
        return;
    }

    QObject::disconnect(m_connections[item].first);
    QObject::disconnect(m_connections[item].second);

    resetItem(item, m_mode);
}

void SizeGroup::resetItem(QQuickItem *item, Modes forMode)
{
    if (!qmlEngine(item) || !qmlContext(item)) {
        return;
    }

    if (forMode & Mode::Width) {
        QQmlProperty(item, QStringLiteral("Layout.preferredWidth"), qmlContext(item)).write(-1);
    }
    if (forMode & Mode::Height) {
        QQmlProperty(item, QStringLiteral("Layout.preferredHeight"), qmlContext(item)).write(-1);
    }
}

QQmlListProperty<QQuickItem> SizeGroup::items()
{
    return QQmlListProperty<QQuickItem>(this, //
                                        nullptr,
                                        appendItem,
                                        itemCount,
                                        itemAt,
                                        clearItems);
}

SizeGroup::Modes SizeGroup::mode() const
{
    return m_mode;
}

void SizeGroup::setMode(Modes mode)
{
    if (m_mode == mode) {
        return;
    }

    Modes reset = m_mode & ~mode;
    if (reset != Mode::None) {
        for (const auto &item : std::as_const(m_items)) {
            resetItem(item, reset);
        }
    }

    m_mode = mode;
    Q_EMIT modeChanged();

    relayout();
}

void SizeGroup::relayout()
{
    adjustItems(Mode::Both);
}

void SizeGroup::componentComplete()
{
    adjustItems(Mode::Both);
}

void SizeGroup::adjustItems(Modes whatChanged)
{
    if (m_mode == Mode::Width && whatChanged == Mode::Height) {
        return;
    }
    if (m_mode == Mode::Height && whatChanged == Mode::Width) {
        return;
    }

    m_maxWidth = 0.0;
    m_maxHeight = 0.0;

    for (const auto &item : std::as_const(m_items)) {
        if (item == nullptr) {
            continue;
        }

        if (m_mode & Mode::Width) {
            m_maxWidth = qMax(m_maxWidth, item->implicitWidth());
        }
        if (m_mode & Mode::Height) {
            m_maxHeight = qMax(m_maxHeight, item->implicitHeight());
        }
    }

    Q_EMIT maxWidthChanged();
    Q_EMIT maxHeightChanged();

    for (const auto &item : std::as_const(m_items)) {
        if (item == nullptr) {
            continue;
        }

        if (!qmlEngine(item) || !qmlContext(item)) {
            continue;
        }

        if (m_mode & Mode::Width) {
            QQmlProperty(item, QStringLiteral("Layout.preferredWidth"), qmlContext(item)).write(m_maxWidth);
        }
        if (m_mode & Mode::Height) {
            QQmlProperty(item, QStringLiteral("Layout.preferredHeight"), qmlContext(item)).write(m_maxHeight);
        }
    }
}
