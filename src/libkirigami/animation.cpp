/*
 *  SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#include "animation.h"

namespace Kirigami
{

// in case we want to expand this in the future
class AnimationPrivate
{
    Q_DISABLE_COPY(AnimationPrivate)

public:
    explicit AnimationPrivate()
        : visibleToHidden(QEasingCurve::OutCubic)
        , visibleToVisible(QEasingCurve::InOutCubic)
        , hiddenToVisible(QEasingCurve::OutCubic)
    {
    }

    QEasingCurve::Type visibleToHidden;
    QEasingCurve::Type visibleToVisible;
    QEasingCurve::Type hiddenToVisible;
};

Animation::Animation(QObject *parent)
    : QObject(parent)
    , d(std::make_unique<AnimationPrivate>())
{
}

Animation::~Animation() = default;

QEasingCurve::Type Animation::visibleToHidden() const
{
    return d->visibleToHidden;
}

QEasingCurve::Type Animation::visibleToVisible() const
{
    return d->visibleToVisible;
}

QEasingCurve::Type Animation::hiddenToVisible() const
{
    return d->hiddenToVisible;
}

};
