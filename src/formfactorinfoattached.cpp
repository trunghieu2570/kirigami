/*
 *  SPDX-FileCopyrightText: 2021 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#include "formfactorinfoattached.h"

#include <QDebug>
#include <QQuickItem>
#include <QQuickWindow>

QHash<QWindow *, Kirigami::FormFactorInfo *> FormFactorInfoAttached::s_infoForWindow = QHash<QWindow *, Kirigami::FormFactorInfo *>();

FormFactorInfoAttached::FormFactorInfoAttached(QObject *parent)
    : QObject(parent)
{
    
}

FormFactorInfoAttached::~FormFactorInfoAttached()
{
}

Kirigami::FormFactorInfo::ScreenType FormFactorInfoAttached::screenType() const
{
    if (!m_formFactorInfo) {
        return Kirigami::FormFactorInfo::Desktop;
    }
    return m_formFactorInfo->screenType();
}

Kirigami::FormFactorInfo::ScreenTypes FormFactorInfoAttached::availableScreenTypes() const
{
    if (!m_formFactorInfo) {
        return Kirigami::FormFactorInfo::Desktop;
    }
    return m_formFactorInfo->availableScreenTypes();
}


Kirigami::FormFactorInfo::InputType FormFactorInfoAttached::primaryInputType() const
{
    if (!m_formFactorInfo) {
        return Kirigami::FormFactorInfo::PointingDevice;
    }
    return m_formFactorInfo->primaryInputType();
}

Kirigami::FormFactorInfo::InputType FormFactorInfoAttached::transientInputType() const
{
    if (!m_formFactorInfo) {
        return Kirigami::FormFactorInfo::PointingDevice;
    }
    return m_formFactorInfo->transientInputType();
}

Kirigami::FormFactorInfo::InputTypes FormFactorInfoAttached::availableInputTypes() const
{
    if (!m_formFactorInfo) {
        return Kirigami::FormFactorInfo::PointingDevice;
    }
    return m_formFactorInfo->availableInputTypes();
}

void FormFactorInfoAttached::setFormFactorInfo(Kirigami::FormFactorInfo *info)
{
    if (m_formFactorInfo == info || !info) {
        return;
    }

    Kirigami::FormFactorInfo *oldInfo = m_formFactorInfo;

    if (oldInfo) {
        disconnect(oldInfo, nullptr, this, nullptr);
    }

    m_formFactorInfo = info;

    connect(info, &Kirigami::FormFactorInfo::screenTypeChanged, this, &FormFactorInfoAttached::screenTypeChanged);
    connect(info, &Kirigami::FormFactorInfo::availableInputTypesChanged, this, &FormFactorInfoAttached::availableInputTypesChanged);
    connect(info, &Kirigami::FormFactorInfo::primaryInputTypeChanged, this, &FormFactorInfoAttached::primaryInputTypeChanged);
    connect(info, &Kirigami::FormFactorInfo::transientInputTypeChanged, this, &FormFactorInfoAttached::transientInputTypeChanged);
    connect(info, &Kirigami::FormFactorInfo::availableInputTypesChanged, this, &FormFactorInfoAttached::availableInputTypesChanged);

    if (!oldInfo || oldInfo->screenType() != info->screenType()) {
        Q_EMIT screenTypeChanged();
    }
    if (!oldInfo || oldInfo->availableInputTypes() != info->availableScreenTypes()) {
        Q_EMIT availableScreenTypesChanged();
    }
    if (!oldInfo || oldInfo->primaryInputType() != info->primaryInputType()) {
        Q_EMIT primaryInputTypeChanged();
    }
    if (!oldInfo || oldInfo->transientInputType() != info->transientInputType()) {
        Q_EMIT transientInputTypeChanged();
    }
    if (!oldInfo || oldInfo->availableInputTypes() != info->availableInputTypes()) {
        Q_EMIT availableInputTypesChanged();
    }
}

void FormFactorInfoAttached::syncFormFactorInfo()
{
    QQuickItem *item = qobject_cast<QQuickItem *>(parent());
    if (!item) {
        return;
    }

    QWindow *window = item->window();
    if (window) {
        if (!s_infoForWindow.contains(window)) {
            Kirigami::FormFactorInfo *info = new Kirigami::FormFactorInfo(window, window);
            s_infoForWindow[window] = info;
        }
        setFormFactorInfo(s_infoForWindow[window]);
    }
}

FormFactorInfoAttached *FormFactorInfoAttached::qmlAttachedProperties(QObject *object)
{
    FormFactorInfoAttached *attached = new FormFactorInfoAttached(object);

    QQuickItem *item = qobject_cast<QQuickItem *>(object);
    if (item) {
        QWindow *window = item->window();
        if (window) {
            if (!s_infoForWindow.contains(window)) {
                Kirigami::FormFactorInfo *info = new Kirigami::FormFactorInfo(window, window);
                s_infoForWindow[window] = info;
            }
            attached->setFormFactorInfo(s_infoForWindow[window]);
        }
        connect(item, &QQuickItem::windowChanged, attached, &FormFactorInfoAttached::syncFormFactorInfo);
    }

    return attached;
}

#include "moc_formfactorinfoattached.cpp"
