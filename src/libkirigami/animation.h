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

/**
 * @class Animation animation.h <Kirigami/Animation>
 *
 * A set of useful animation utilities.
 */
class KIRIGAMI2_EXPORT Animation : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int opacityHiddenToVisible READ opacityHiddenToVisible CONSTANT)
    Q_PROPERTY(int movementHiddenToVisible READ movementHiddenToVisible CONSTANT)
    Q_PROPERTY(int opacityVisibleToHidden READ opacityVisibleToHidden CONSTANT)
    Q_PROPERTY(int movementVisibleToHidden READ movementVisibleToHidden CONSTANT)
    Q_PROPERTY(int opacityVisibleToVisible READ opacityVisibleToVisible CONSTANT)
    Q_PROPERTY(int movementVisibleToVisible READ movementVisibleToVisible CONSTANT)

public:
    explicit Animation(QObject *parent = nullptr);
    ~Animation() override;

    QEasingCurve::Type opacityHiddenToVisible() const;
    QEasingCurve::Type movementHiddenToVisible() const;
    QEasingCurve::Type opacityVisibleToHidden() const;
    QEasingCurve::Type movementVisibleToHidden() const;
    QEasingCurve::Type opacityVisibleToVisible() const;
    QEasingCurve::Type movementVisibleToVisible() const;
};

}
