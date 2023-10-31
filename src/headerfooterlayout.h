/*
 *  SPDX-FileCopyrightText: 2023 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */
#ifndef HEADERFOOTERLAYOUT_H
#define HEADERFOOTERLAYOUT_H

#include <QQuickItem>
#include <qtmetamacros.h>

/**
 * replicates a little part of what Page does,
 * It's a container with 3 properties, header, contentItem and footer
 * which will be laid out oone on top of each other. It works better than a
 * ColumnLayout when the elements are to be defined by properties by the
 * user, which would require ugly reparenting dances and container items to
 * maintain the layout well behaving.
 */
class HeaderFooterLayout : public QQuickItem
{
    Q_OBJECT
    /**
     * @brief This property holds the page header item.
     *
     * The header item is positioned to the top,
     * and resized to the width of the page. The default value is null.
     */
    Q_PROPERTY(QQuickItem *header READ header WRITE setHeader NOTIFY headerChanged FINAL)

    /**
     * @brief This property holds the visual content Item.
     *
     * It will be resized both in width and height with the layout resizing.
     * Its height will be resized to still have room for the heder and footer
     */
    Q_PROPERTY(QQuickItem *contentItem READ contentItem WRITE setContentItem NOTIFY contentItemChanged FINAL)

    /**
     * @brief This property holds the page footer item.
     *
     * The footer item is positioned to the bottom,
     * and resized to the width of the page. The default value is null.
     */
    Q_PROPERTY(QQuickItem *footer READ footer WRITE setFooter NOTIFY footerChanged FINAL)

public:
    HeaderFooterLayout(QQuickItem *parent = nullptr);
    ~HeaderFooterLayout() override;

    void setHeader(QQuickItem *item);
    QQuickItem *header();

    void setContentItem(QQuickItem *item);
    QQuickItem *contentItem();

    void setFooter(QQuickItem *item);
    QQuickItem *footer();

Q_SIGNALS:
    void headerChanged();
    void contentItemChanged();
    void footerChanged();

protected:
    void geometryChange(const QRectF &newGeometry, const QRectF &oldGeometry) override;
    void updatePolish() override;

private:
    void calculateImplicitSize();
    void disconnectItem(QQuickItem *item);

    QPointer<QQuickItem> m_header;
    QPointer<QQuickItem> m_contentItem;
    QPointer<QQuickItem> m_footer;
    QTimer *m_sizeHintTimer;
};

#endif
