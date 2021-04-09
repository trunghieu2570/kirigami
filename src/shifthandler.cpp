// SPDX-FileCopyrightText: 2021 Carl Schwan <carlschwan@kde.org>
// SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL

#include "shifthandler.h"

#include <QKeyEvent>

ShiftHandler::ShiftHandler(QObject *parent)
    : QObject(parent)
{
}

QObject *ShiftHandler::target() const
{
    return m_target;
}

void ShiftHandler::setTarget(QObject *target)
{
    if (m_target == target) {
        return;
    }
    if (m_target) {
        m_target->removeEventFilter(this);
    }
    m_target = target;
    if (m_target) {
        m_target->installEventFilter(this);
    }
    Q_EMIT targetChanged();
}

bool ShiftHandler::shiftPressed() const
{
    return m_shiftPressed;
}

bool ShiftHandler::eventFilter(QObject *object, QEvent *event)
{
    if (event->type() == QEvent::KeyPress) {
        QKeyEvent *keyEvent = static_cast<QKeyEvent *>(event);
        if (keyEvent->key() == Qt::Key_Shift) {
            m_shiftPressed = true;
            Q_EMIT shiftPressedChanged();
        }
        return true;
    }
    if (event->type() == QEvent::KeyRelease) {
        QKeyEvent *keyEvent = static_cast<QKeyEvent *>(event);
        if (keyEvent->key() == Qt::Key_Shift) {
            m_shiftPressed = false;
            Q_EMIT shiftPressedChanged();
        }
        return true;
    }
    return false;
}
