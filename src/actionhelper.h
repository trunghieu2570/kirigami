/*
 *  SPDX-FileCopyrightText: 2023 ivan tkachenko <me@ratijas.tk>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#ifndef ACTIONHELPER_H
#define ACTIONHELPER_H

#include <QColor>
#include <QObject>
#include <QQmlListProperty>
#include <QQmlParserStatus>
#include <QQuickItem>

class ActionHelper : public QObject, public QQmlParserStatus
{
    Q_OBJECT
    Q_INTERFACES(QQmlParserStatus)

    // Q_PROPERTY(QObject *action READ action WRITE setAction CONSTANT)
    Q_PROPERTY(QQmlListProperty<QObject> visibleChildren READ visibleChildren NOTIFY visibleChildrenChanged)

    // Q_PROPERTY(QVariant actionType READ actionType WRITE setActionType CONSTANT)

public:
    explicit ActionHelper(QObject *parent = nullptr);
    ~ActionHelper();

    // QObject *action() const;
    // void setAction(QObject *action);

    // QVariant actionType() const;
    // void setActionType(const QVariant &type);

    QQmlListProperty<QObject> visibleChildren();

    // static ActionHelper *qmlAttachedProperties(QObject *);

    void classBegin() override;
    void componentComplete() override;

Q_SIGNALS:
    void visibleChildrenChanged();

private Q_SLOTS:
    void updateChildren();

private:
    static qsizetype list_count(QQmlListProperty<QObject> *list);
    static QObject *list_at(QQmlListProperty<QObject> *list, qsizetype index);

    void setUp();
    QQmlListReference children();
    QList<QObject *> collectChildren();

    QList<QPointer<QObject>> m_children;
};

#endif
