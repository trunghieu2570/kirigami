// SPDX-FileCopyrightText: 2020 Carson Black <uhhadd@gmail.com>
//
// SPDX-License-Identifier: LGPL-2.0-or-later

#pragma once

#include <QColor>
#include <QObject>
#include <QPointer>

class NameUtils : public QObject
{
    Q_OBJECT

public:
    Q_INVOKABLE QString initialsFromString(const QString &name);
    Q_INVOKABLE QColor colorsFromString(const QString &name);
    Q_INVOKABLE bool isStringUnsuitableForInitials(const QString &name);
};

class AvatarGroup : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QObject *main READ mainAction WRITE setMainAction NOTIFY mainActionChanged)
    Q_PROPERTY(QObject *secondary READ secondaryAction WRITE setSecondaryAction NOTIFY secondaryActionChanged)

public:
    QObject *mainAction() const;
    void setMainAction(QObject *action = nullptr);

    QObject *secondaryAction() const;
    void setSecondaryAction(QObject *action = nullptr);

Q_SIGNALS:
    void mainActionChanged();
    void secondaryActionChanged();

private:
    void setAction(QObject *action, QPointer<QObject> &member, void (AvatarGroup::*signal)());

    QPointer<QObject> m_mainAction;
    QPointer<QObject> m_secondaryAction;
};
