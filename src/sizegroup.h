/*
 *  SPDX-FileCopyrightText: 2020 Carson Black <uhhadd@gmail.com>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#pragma once

#include <QMap>
#include <QObject>
#include <QPair>
#include <QPointer>
#include <QQmlListProperty>
#include <QQmlParserStatus>
#include <QQuickItem>

/**
 * @brief SizeGroup is a utility object that makes groups of items request the
 * same size.
 *
 * This can be instantiated to automatically manage the height, width, or both
 * sizes of multiple items based on the item with the highest value. In other
 * words, if widths are synchronized, all items being managed by a SizeGroup
 * will have the same preferredWidth as the item with the largest implicitWidth.
 *
 * Pass a JavaScript array of ::items to be managed by this object, then set the
 * ::mode property to define which size to synchronize.
 *
 * @note Manually setting a width or height for items managed by a SizeGroup
 * will override the width or height calculated by the instantiated SizeGroup.
 *
 * @note All objects managed by a SizeGroup must belong to a Layout. This
 * includes Kirigami-specific Layouts such as kirigami::FormLayout.
 *
 * @include sizegroup.qml
 */
class SizeGroup : public QObject, public QQmlParserStatus
{
    Q_OBJECT
    Q_INTERFACES(QQmlParserStatus)

public:
    enum Mode {
        /**
         * @brief SizeGroup does nothing.
         */
        None = 0,

        /**
         * @brief SizeGroup syncs item widths.
         */
        Width = 1,

        /**
         * @brief SizeGroup syncs item heights.
         */
        Height = 2,

        /**
         * @brief SizeGroup syncs both item widths and heights
         */
        Both = 3,
    };
    Q_ENUM(Mode)
    Q_DECLARE_FLAGS(Modes, Mode)

private:
    Mode m_mode = None;
    QList<QPointer<QQuickItem>> m_items;
    QMap<QQuickItem *, QPair<QMetaObject::Connection, QMetaObject::Connection>> m_connections;

public:
    /**
     * @brief This property sets which dimensions this SizeGroup should sync.
     */
    Q_PROPERTY(Mode mode MEMBER m_mode NOTIFY modeChanged)
    Q_SIGNAL void modeChanged();

    /**
     * @brief This property holds a list of items this SizeGroup should adjust.
     */
    Q_PROPERTY(QQmlListProperty<QQuickItem> items READ items CONSTANT)
    QQmlListProperty<QQuickItem> items();

    void adjustItems(Mode whatChanged);
    void connectItem(QQuickItem *item);

    /**
     * @brief This method forces the SizeGroup to relayout its items.
     *
     * Normally this is never needed as the SizeGroup automatically relayouts
     * items as they're added and their sizes change.
     */
    Q_INVOKABLE void relayout();

    void classBegin() override
    {
    }
    void componentComplete() override;

private:
    static void appendItem(QQmlListProperty<QQuickItem> *prop, QQuickItem *value);
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    static int itemCount(QQmlListProperty<QQuickItem> *prop);
    static QQuickItem *itemAt(QQmlListProperty<QQuickItem> *prop, int index);
#else
    static qsizetype itemCount(QQmlListProperty<QQuickItem> *prop);
    static QQuickItem *itemAt(QQmlListProperty<QQuickItem> *prop, qsizetype index);
#endif
    static void clearItems(QQmlListProperty<QQuickItem> *prop);
};
