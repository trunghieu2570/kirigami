// SPDX-FileCopyrightText: 2021 Carl Schwan <carlschwan@kde.org>
// SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL

#pragma once

#include <QObject>

/// Handler detecting if the shift key is pressed. This is private API.
/// \internal
class ShiftHandler : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QObject *target READ target WRITE setTarget NOTIFY targetChanged)
    Q_PROPERTY(bool shiftPressed READ shiftPressed NOTIFY shiftPressedChanged)
public:
    ShiftHandler(QObject *parent = nullptr);
    QObject *target() const;
    void setTarget(QObject *target);
    bool shiftPressed() const;

    bool eventFilter(QObject *object, QEvent *event) override;

Q_SIGNALS:
    void targetChanged();
    void shiftPressedChanged();

private:
    QObject *m_target = nullptr;
    bool m_shiftPressed = false;
};
