/*
 *  SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#pragma once

#include <QEasingCurve>
#include <QObject>

#include <memory>

#include "kirigami2_export.h"

class QQmlEngine;

namespace Kirigami
{
class AnimationPrivate;

/**
 * @class Units units.h <Kirigami/Animation>
 *
 * A set of useful animation utilities.
 */
class KIRIGAMI2_EXPORT Animation : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int visibleToHidden READ visibleToHidden NOTIFY visibleToHiddenChanged)
    Q_PROPERTY(int visibleToVisible READ visibleToVisible NOTIFY visibleToVisibleChanged)
    Q_PROPERTY(int hiddenToVisible READ hiddenToVisible NOTIFY hiddenToVisibleChanged)

public:
    explicit Animation(QObject *parent = nullptr);
    ~Animation() override;

    QEasingCurve::Type visibleToHidden() const;
    QEasingCurve::Type visibleToVisible() const;
    QEasingCurve::Type hiddenToVisible() const;

Q_SIGNALS:
    void visibleToHiddenChanged();
    void visibleToVisibleChanged();
    void hiddenToVisibleChanged();

private:
    std::unique_ptr<AnimationPrivate> d;
};

}
