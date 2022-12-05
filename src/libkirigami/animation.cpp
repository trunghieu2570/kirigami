/*
 *  SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#include "animation.h"

namespace Kirigami
{

Animation::Animation(QObject *parent)
    : QObject(parent)
{
}

Animation::~Animation() = default;

QEasingCurve::Type Animation::opacityHiddenToVisible() const
{
    return QEasingCurve::InOutCubic;
}

QEasingCurve::Type Animation::movementHiddenToVisible() const
{
    return QEasingCurve::OutCubic;
}

QEasingCurve::Type Animation::opacityVisibleToHidden() const
{
    return QEasingCurve::InOutCubic;
}

QEasingCurve::Type Animation::movementVisibleToHidden() const
{
    return QEasingCurve::OutCubic;
}

QEasingCurve::Type Animation::opacityVisibleToVisible() const
{
    return QEasingCurve::InOutCubic;
}

QEasingCurve::Type Animation::movementVisibleToVisible() const
{
    return QEasingCurve::InOutCubic;
}

};
