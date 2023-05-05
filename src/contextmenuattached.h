/*
 *  SPDX-FileCopyrightText: 2023 Joshua Goins <josh@redstrate.com>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */
#pragma once

#include <QObject>
#include <QtQml>

class QQuickItem;

class ContextMenuAttached : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QQmlListProperty<QQuickItem> items READ items CONSTANT)

public:
    explicit ContextMenuAttached(QObject *parent = nullptr);

    QQmlListProperty<QQuickItem> items();

    // QML attached property
    static ContextMenuAttached *qmlAttachedProperties(QObject *object);

Q_SIGNALS:
    void aboutToShow(int x, int y);

private:
    static void appendItem(QQmlListProperty<QQuickItem> *prop, QQuickItem *value);
    static int itemCount(QQmlListProperty<QQuickItem> *prop);
    static QQuickItem *itemAt(QQmlListProperty<QQuickItem> *prop, int index);
    static void clearItems(QQmlListProperty<QQuickItem> *prop);

    QVector<QQuickItem *> m_items;
};

QML_DECLARE_TYPEINFO(ContextMenuAttached, QML_HAS_ATTACHED_PROPERTIES)
