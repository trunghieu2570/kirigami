/*
 *  SPDX-FileCopyrightText: 2023 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#include "headerfooterlayout.h"

#include <QDebug>
#include <QTimer>

HeaderFooterLayout::HeaderFooterLayout(QQuickItem *parent)
    : QQuickItem(parent)
{
    m_sizeHintTimer = new QTimer(this);
    m_sizeHintTimer->setInterval(0);
    m_sizeHintTimer->setSingleShot(true);
    connect(m_sizeHintTimer, &QTimer::timeout, this, &HeaderFooterLayout::calculateImplicitSize);
}

HeaderFooterLayout::~HeaderFooterLayout()
{
    disconnectItem(m_header);
    disconnectItem(m_contentItem);
    disconnectItem(m_footer);
};

void HeaderFooterLayout::setHeader(QQuickItem *item)
{
    if (m_header == item) {
        return;
    }

    if (m_header) {
        disconnectItem(m_header);
        m_header->setParentItem(nullptr);
    }

    m_header = item;

    if (m_header) {
        m_header->setParentItem(this);
        if (m_header->z() == 0) {
            m_header->setZ(1);
        }

        connect(m_header, &QQuickItem::implicitWidthChanged, m_sizeHintTimer, qOverload<>(&QTimer::start));
        connect(m_header, &QQuickItem::implicitHeightChanged, m_sizeHintTimer, qOverload<>(&QTimer::start));
        connect(m_header, &QQuickItem::visibleChanged, m_sizeHintTimer, qOverload<>(&QTimer::start));

        if (m_header->inherits("QQuickTabBar") || m_header->inherits("QQuickToolBar") || m_header->inherits("QQuickDialogButtonBox")) {
            // Assume 0 is Header for all 3 types
            m_header->setProperty("position", 0);
        }
    }
    calculateImplicitSize();

    Q_EMIT headerChanged();
}

QQuickItem *HeaderFooterLayout::header()
{
    return m_header;
}

void HeaderFooterLayout::setContentItem(QQuickItem *item)
{
    if (m_contentItem == item) {
        return;
    }

    if (m_contentItem) {
        disconnectItem(m_contentItem);
        m_contentItem->setParentItem(nullptr);
    }

    m_contentItem = item;

    if (m_contentItem) {
        m_contentItem->setParentItem(this);
        connect(m_contentItem, &QQuickItem::implicitWidthChanged, m_sizeHintTimer, qOverload<>(&QTimer::start));
        connect(m_contentItem, &QQuickItem::implicitHeightChanged, m_sizeHintTimer, qOverload<>(&QTimer::start));
        connect(m_contentItem, &QQuickItem::visibleChanged, m_sizeHintTimer, qOverload<>(&QTimer::start));
    }

    calculateImplicitSize();

    Q_EMIT contentItemChanged();
}

QQuickItem *HeaderFooterLayout::contentItem()
{
    return m_contentItem;
}

void HeaderFooterLayout::setFooter(QQuickItem *item)
{
    if (m_footer == item) {
        return;
    }

    if (m_footer) {
        disconnectItem(m_footer);
        m_footer->setParentItem(nullptr);
    }

    m_footer = item;

    if (m_footer) {
        m_footer->setParentItem(this);
        if (m_footer->z() == 0) {
            m_footer->setZ(1);
        }

        connect(m_footer, &QQuickItem::implicitWidthChanged, m_sizeHintTimer, qOverload<>(&QTimer::start));
        connect(m_footer, &QQuickItem::implicitHeightChanged, m_sizeHintTimer, qOverload<>(&QTimer::start));
        connect(m_footer, &QQuickItem::visibleChanged, m_sizeHintTimer, qOverload<>(&QTimer::start));

        if (m_footer->inherits("QQuickTabBar") || m_footer->inherits("QQuickToolBar") || m_footer->inherits("QQuickDialogButtonBox")) {
            // Assume 1 is Footer for all 3 types
            m_footer->setProperty("position", 1);
        }
    }

    calculateImplicitSize();

    Q_EMIT footerChanged();
}

QQuickItem *HeaderFooterLayout::footer()
{
    return m_footer;
}

void HeaderFooterLayout::geometryChange(const QRectF &newGeometry, const QRectF &oldGeometry)
{
    if (newGeometry != oldGeometry) {
        polish();
    }

    QQuickItem::geometryChange(newGeometry, oldGeometry);
}

void HeaderFooterLayout::updatePolish()
{
    const QSizeF newSize = size();
    qreal headerHeight = 0;
    qreal footerHeight = 0;

    if (m_header) {
        m_header->setWidth(newSize.width());
        if (m_header->isVisible()) {
            headerHeight += m_header->height();
        }
    }
    if (m_footer) {
        m_footer->setY(newSize.height() - m_footer->height());
        m_footer->setWidth(newSize.width());
        if (m_footer->isVisible()) {
            footerHeight += m_footer->height();
        }
    }
    if (m_contentItem) {
        m_contentItem->setY(headerHeight);
        m_contentItem->setWidth(newSize.width());
        m_contentItem->setHeight(newSize.height() - headerHeight - footerHeight);
    }
}

void HeaderFooterLayout::calculateImplicitSize()
{
    qreal impWidth = 0;
    qreal impHeight = 0;

    if (m_header && m_header->isVisible()) {
        impWidth = std::max(impWidth, m_header->implicitWidth());
        impHeight += m_header->implicitHeight();
    }
    if (m_footer && m_footer->isVisible()) {
        impWidth = std::max(impWidth, m_footer->implicitWidth());
        impHeight += m_footer->implicitHeight();
    }
    if (m_contentItem && m_contentItem->isVisible()) {
        impWidth = std::max(impWidth, m_contentItem->implicitWidth());
        impHeight += m_contentItem->implicitHeight();
    }
    setImplicitSize(impWidth, impHeight);
    polish();
}

void HeaderFooterLayout::disconnectItem(QQuickItem *item)
{
    if (item) {
        disconnect(item, &QQuickItem::implicitWidthChanged, m_sizeHintTimer, nullptr);
        disconnect(item, &QQuickItem::implicitHeightChanged, m_sizeHintTimer, nullptr);
        disconnect(item, &QQuickItem::visibleChanged, m_sizeHintTimer, nullptr);
    }
}

#include "moc_headerfooterlayout.cpp"
