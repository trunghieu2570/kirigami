/*
 *  SPDX-FileCopyrightText: 2021 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#pragma once

#include <QObject>

class QWindow;

namespace Kirigami
{
class FormFactorInfoPrivate;

/**
 * @since 5.83
 * @since org.kde.kirigami 2.17
 */
class FormFactorInfo : public QObject
{
    Q_OBJECT

    /**
     * @returns The formfactor of the screen this application is rendering to (desktop, phone etc)
     */
    Q_PROPERTY(ScreenType screenType READ screenType NOTIFY screenTypeChanged)

    Q_PROPERTY(ScreenTypes availableScreenTypes READ availableScreenTypes NOTIFY availableScreenTypesChanged)

    Q_PROPERTY(InputType primaryInputType READ primaryInputType NOTIFY primaryInputTypeChanged)

    /**
     * @returns The last kind of input that has been employed by the user, which may also be different from the primary one (for instance touchscreen on a laptop)
     */
    Q_PROPERTY(InputType transientInputType READ transientInputType NOTIFY transientInputTypeChanged)

    Q_PROPERTY(InputTypes availableInputTypes READ availableInputTypes NOTIFY availableInputTypesChanged)

public:
    enum ScreenType {
        NoScreen = 0x0,
        Desktop = 0x1,
        Tablet = 0x2,
        Handheld = 0x4,
        TV = 0x8
    };
    Q_ENUM(ScreenType)
    Q_DECLARE_FLAGS(ScreenTypes, ScreenType)
    Q_FLAG(ScreenTypes)

    enum InputType {
        NoInput = 0x0,
        PointingDevice = 0x1, /*We can't realistically distinguish between mouse and touchpas i guess, also, api simplicity*/
        Touch = 0x2,
        Pen, /*not yet?*/
        Keyboard = 0x4,
        RemoteControl = 0x8
    };
    Q_ENUM(InputType)
    Q_DECLARE_FLAGS(InputTypes, InputType)
    Q_FLAG(InputTypes)

    FormFactorInfo(QWindow *window);
    ~FormFactorInfo();

    QWindow *window() const;

    ScreenType screenType() const;
    ScreenTypes availableScreenTypes() const;

    InputType primaryInputType() const;
    InputType transientInputType() const;
    InputTypes availableInputTypes() const;

protected:
    bool eventFilter(QObject *watched, QEvent *event) override;

Q_SIGNALS:
    void screenTypeChanged(ScreenType type);
    void availableScreenTypesChanged(ScreenTypes types);
    void primaryInputTypeChanged(InputType type);
    void transientInputTypeChanged(InputType type);
    void availableInputTypesChanged(InputTypes types);

private:
    FormFactorInfoPrivate *d;
};

Q_DECLARE_OPERATORS_FOR_FLAGS(FormFactorInfo::ScreenTypes)
Q_DECLARE_OPERATORS_FOR_FLAGS(FormFactorInfo::InputTypes)

}
