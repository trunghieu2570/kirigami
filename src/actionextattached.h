/*
 *  SPDX-FileCopyrightText: 2023 ivan tkachenko <me@ratijas.tk>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#ifndef ACTIONEXTATTACHED_H
#define ACTIONEXTATTACHED_H

#include <QObject>
#include <QQmlEngine>

#include "enums.h"

class QQmlComponent;

/**
 * This class provides various extensions for QtQuick.Controls/Action type.
 *
 * Note: This new type is a replacement to the deprecated standalone
 * Kirigami.Action type. When attached to Kirigami.Action, it will synchronize
 * properties both ways for backward compatibility. New code should use
 * QtQuick.Templates/Action for typing purposes (e.g. defining custom
 * properties) and get/set ActionExt properties on regular actions.
 */
class ActionExtAttached : public QObject
{
    Q_OBJECT
    /**
     * This property holds whether the graphic representation of the action
     * is supposed to be visible.
     *
     * It's up to the action representation to honor this property.
     *
     * default: ``true``
     */
    Q_PROPERTY(bool visible READ isVisible WRITE setVisible NOTIFY visibleChanged FINAL)

    // TODO: add other properties from Kirigami.Action

public:
    explicit ActionExtAttached(QObject *parent = nullptr);
    ~ActionExtAttached() override;

    bool isVisible() const;
    void setVisible(bool);

    // QML attached property
    static ActionExtAttached *qmlAttachedProperties(QObject *object);

Q_SIGNALS:
    void visibleChanged();

private Q_SLOTS:
    void syncVisible();

private:
    // TODO: Move to a private class? Not comfortable with (private) slots leaking into runtime
    QString m_tooltip;
    quint32 m_visible : 1;
    quint32 m_separator : 1;
    quint32 m_expandible : 1;
    DisplayHint::DisplayHints m_displayHints;
    QQmlComponent *m_displayComponent;
    ActionExtAttached *m_parentActionExt;
    QList<ActionExtAttached *> m_children;

    static bool isQQC2Action(const QObject *object);
    static bool isKirigamiAction(const QObject *object);
    void bindKirigamiActionParent();
};

QML_DECLARE_TYPEINFO(ActionExtAttached, QML_HAS_ATTACHED_PROPERTIES)

#endif // ACTIONEXTATTACHED_H
