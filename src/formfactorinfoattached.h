/*
 *  SPDX-FileCopyrightText: 2021 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#pragma once

#include <QObject>
#include <QPointer>
#include <QtQml>
#include "libkirigami/formfactorinfo.h"


/**
 * @since 5.83
 * @since org.kde.kirigami 2.17
 */
class FormFactorInfoAttached : public QObject
{
    Q_OBJECT

    /**
     * @returns The formfactor of the screen this application is rendering to (desktop, phone etc)
     */
    Q_PROPERTY(Kirigami::FormFactorInfo::ScreenType screenType READ screenType NOTIFY screenTypeChanged)

    Q_PROPERTY(Kirigami::FormFactorInfo::ScreenTypes availableScreenTypes READ availableScreenTypes NOTIFY availableScreenTypesChanged)

    Q_PROPERTY(Kirigami::FormFactorInfo::InputType primaryInputType READ primaryInputType NOTIFY primaryInputTypeChanged)

    /**
     * @returns The last kind of input that has been employed by the user, which may also be different from the primary one (for instance touchscreen on a laptop)
     */
    Q_PROPERTY(Kirigami::FormFactorInfo::InputType transientInputType READ transientInputType NOTIFY transientInputTypeChanged)

    Q_PROPERTY(Kirigami::FormFactorInfo::InputTypes availableInputTypes READ availableInputTypes NOTIFY availableInputTypesChanged)

public:
    FormFactorInfoAttached(QObject *parent = 0);
    ~FormFactorInfoAttached();

    Kirigami::FormFactorInfo::ScreenType screenType() const;
    Kirigami::FormFactorInfo::ScreenTypes availableScreenTypes() const;

    Kirigami::FormFactorInfo::InputType primaryInputType() const;
    Kirigami::FormFactorInfo::InputType transientInputType() const;
    Kirigami::FormFactorInfo::InputTypes availableInputTypes() const;

    void setFormFactorInfo(Kirigami::FormFactorInfo *info);

    // QML attached property
    static FormFactorInfoAttached *qmlAttachedProperties(QObject *object);

Q_SIGNALS:
    void screenTypeChanged();
    void availableScreenTypesChanged();
    void primaryInputTypeChanged();
    void transientInputTypeChanged();
    void availableInputTypesChanged();

private:
    QPointer<Kirigami::FormFactorInfo> m_formFactorInfo;
    static QHash<QWindow *, Kirigami::FormFactorInfo *> s_infoForWindow;
};

QML_DECLARE_TYPEINFO(FormFactorInfoAttached, QML_HAS_ATTACHED_PROPERTIES)

