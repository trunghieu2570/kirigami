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
 * SizeGroup is a utility object that makes groups of items request the same size.
 */
class SizeGroup : public QObject, public QQmlParserStatus
{
    Q_OBJECT
    Q_PROPERTY(Modes mode READ mode WRITE setMode NOTIFY modeChanged)
    Q_PROPERTY(qreal maxWidth MEMBER m_maxWidth NOTIFY maxWidthChanged REVISION 21)
    Q_PROPERTY(qreal maxHeight MEMBER m_maxHeight NOTIFY maxHeightChanged REVISION 21)
    Q_PROPERTY(QQmlListProperty<QQuickItem> items READ items CONSTANT)
    Q_INTERFACES(QQmlParserStatus)

public:
    enum Mode {
        None = 0, /// SizeGroup does nothing
        Width = 1, /// SizeGroup syncs item widths
        Height = 2, /// SizeGroup syncs item heights
        Both = 3, /// SizeGroup syncs both item widths and heights
    };
    Q_DECLARE_FLAGS(Modes, Mode)
    Q_FLAG(Modes)

    /**
     * Which dimensions this SizeGroup should adjust
     */
    Modes mode() const;
    void setMode(Modes mode);

    /**
     * Which items this SizeGroup should adjust
     */
    QQmlListProperty<QQuickItem> items();

    /**
     * Forces the SizeGroup to relayout items.
     *
     * Normally this is never needed as the SizeGroup automatically
     * relayout items as they're added and their sizes change.
     */
    Q_INVOKABLE void relayout();

    void classBegin() override
    {
    }
    void componentComplete() override;

Q_SIGNALS:
    void modeChanged();

    /**
     * Width of the widest item in a group.
     *
     * Only updated when the mode is set to either Width or Both. Defaults to 0.
     *
     * @since 5.97
     */
    Q_REVISION(21) void maxWidthChanged();

    /**
     * Height of the tallest item in a group.
     *
     * Only updated when the mode is set to either Height or Both. Defaults to 0.
     *
     * @since 5.97
     */
    Q_REVISION(21) void maxHeightChanged();

private:
    void connectItem(QQuickItem *item);
    void disconnectItem(QQuickItem *item);
    void resetItem(QQuickItem *item, Modes forMode);
    void adjustItems(Modes whatChanged);

    static void appendItem(QQmlListProperty<QQuickItem> *prop, QQuickItem *value);
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    static int itemCount(QQmlListProperty<QQuickItem> *prop);
    static QQuickItem *itemAt(QQmlListProperty<QQuickItem> *prop, int index);
#else
    static qsizetype itemCount(QQmlListProperty<QQuickItem> *prop);
    static QQuickItem *itemAt(QQmlListProperty<QQuickItem> *prop, qsizetype index);
#endif
    static void clearItems(QQmlListProperty<QQuickItem> *prop);

    Modes m_mode = None;
    qreal m_maxWidth = 0.0;
    qreal m_maxHeight = 0.0;
    QList<QPointer<QQuickItem>> m_items;
    QMap<QQuickItem *, QPair<QMetaObject::Connection, QMetaObject::Connection>> m_connections;
};
