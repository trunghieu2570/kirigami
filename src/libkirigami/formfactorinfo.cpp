/*
 *  SPDX-FileCopyrightText: 2021 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#include "formfactorinfo.h"

#include <QDebug>
#include <QFile>
#include <QGuiApplication>
#include <QMouseEvent>
#include <QStandardPaths>
#include <QTouchDevice>
#include <QWindow>

#include "tabletmodewatcher.h"

#ifndef KIRIGAMI_BUILD_TYPE_STATIC
#include "../../kirigami_version.h"
#endif

namespace Kirigami {

class FormFactorInfoPrivate
{
public:
    FormFactorInfoPrivate(FormFactorInfo *parent);

    void setScreenType(FormFactorInfo::ScreenType type);
    void setPrimaryInputType(FormFactorInfo::InputType type);
    void setTransientInputType(FormFactorInfo::InputType type);

    void setAvailableScreenTypes(FormFactorInfo::ScreenTypes types);
    void addAvailableScreenType(FormFactorInfo::ScreenType type);
    void removeAvailableScreenType(FormFactorInfo::ScreenType type);

    void setAvailableInputTypes(FormFactorInfo::InputTypes types);
    void addAvailableInputType(FormFactorInfo::InputType type);
    void removeAvailableInputType(FormFactorInfo::InputType type);

    FormFactorInfo *q;
    QWindow *m_window;
    FormFactorInfo::ScreenType m_screenType = FormFactorInfo::Desktop;
    FormFactorInfo::ScreenTypes m_availableScreenTypes = FormFactorInfo::Desktop;
    FormFactorInfo::InputType m_primaryInputType = FormFactorInfo::PointingDevice;
    FormFactorInfo::FormFactorInfo::InputType m_transientInputType = FormFactorInfo::PointingDevice;
    FormFactorInfo::InputTypes m_availableInputTypes = FormFactorInfo::PointingDevice | FormFactorInfo::Keyboard;
};

FormFactorInfoPrivate::FormFactorInfoPrivate(FormFactorInfo *parent)
    : q(parent)
{}

void FormFactorInfoPrivate::setScreenType(FormFactorInfo::ScreenType type)
{
    if (m_screenType == type) {
        return;
    }

    m_screenType = type;

    Q_EMIT q->screenTypeChanged(type);
}

void FormFactorInfoPrivate::setPrimaryInputType(FormFactorInfo::InputType type)
{
    if (m_primaryInputType == type) {
        return;
    }

    m_primaryInputType = type;

    Q_EMIT q->primaryInputTypeChanged(type);
}

void FormFactorInfoPrivate::setTransientInputType(FormFactorInfo::InputType type)
{
    if (m_transientInputType == type) {
        return;
    }

    m_transientInputType = type;

    Q_EMIT q->transientInputTypeChanged(type);
}

void FormFactorInfoPrivate::setAvailableScreenTypes(FormFactorInfo::ScreenTypes types)
{
    if (m_availableScreenTypes == types) {
        return;
    }

    m_availableScreenTypes = types;

    Q_EMIT q->availableScreenTypesChanged(types);
}

void FormFactorInfoPrivate::addAvailableScreenType(FormFactorInfo::ScreenType type)
{
    setAvailableScreenTypes(m_availableScreenTypes | type);
}

void FormFactorInfoPrivate::removeAvailableScreenType(FormFactorInfo::ScreenType type)
{
    setAvailableScreenTypes(m_availableScreenTypes & (!type));
}


void FormFactorInfoPrivate::setAvailableInputTypes(FormFactorInfo::InputTypes types)
{
    if (m_availableInputTypes == types) {
        return;
    }

    m_availableInputTypes = types;

    Q_EMIT q->availableInputTypesChanged(types);
}

void FormFactorInfoPrivate::addAvailableInputType(FormFactorInfo::InputType type)
{
    setAvailableInputTypes(m_availableInputTypes | type);
}

void FormFactorInfoPrivate::removeAvailableInputType(FormFactorInfo::InputType type)
{
    setAvailableInputTypes(m_availableInputTypes & (!type));
}


//////////////////////////////////////////////////////////

FormFactorInfo::FormFactorInfo(QWindow *parent)
    : QObject(parent)
    , d(new FormFactorInfoPrivate(this))
{
    d->m_window = parent;

    bool fixedInputType = false;

#if defined(Q_OS_ANDROID) || defined(Q_OS_IOS) || defined(UBUNTU_TOUCH)
    fixedInputType = true;
    d->m_screenType = Handheld; //TODO: phone/tablet difference on Android too
    d->m_primaryInputType = Touch;
    d->m_availableScreenTypes = Handheld;
    d->m_availableInputTypes = Touch;
#else
    // Environment variables which fix everyhting to a single formfactor
    // Mostly for debug purposes and for platforms which are always mobile,
    // such as Plasma Mobile
    if (qEnvironmentVariableIsSet("QT_QUICK_CONTROLS_MOBILE")) {
        if (QByteArrayList{"1", "true"}.contains(qgetenv("QT_QUICK_CONTROLS_MOBILE"))) {
            fixedInputType = true;
            d->m_screenType = Handheld;
            d->m_primaryInputType = Touch;
            d->m_availableScreenTypes = Handheld;
            d->m_availableInputTypes = Touch;
        }

    } else if (qEnvironmentVariableIsSet("KDE_KIRIGAMI_SCREEN_TYPE")
                || qEnvironmentVariableIsSet("KDE_KIRIGAMI_INPUT_TYPE")) {
        const QByteArray screenType = qgetenv("KDE_KIRIGAMI_SCREEN_TYPE");
        if (screenType == "handheld") {
            d->m_screenType = Handheld;
            d->m_availableScreenTypes = Handheld;
        } else if (screenType == "desktop") {
            d->m_screenType = Desktop;
            d->m_availableScreenTypes = Desktop;
        } else if (screenType == "tablet") {
            d->m_screenType = Tablet;
            d->m_availableScreenTypes = Tablet;
        } else if (screenType == "TV") {
            d->m_screenType = TV;
            d->m_availableScreenTypes = TV;
        }

        const QByteArray inputType = qgetenv("KDE_KIRIGAMI_INPUT_TYPE");
        if (screenType == "pointingdevice") {
            fixedInputType = true;
            d->m_primaryInputType = PointingDevice;
            d->m_availableInputTypes = PointingDevice;
        } else if (screenType == "touch") {
            fixedInputType = true;
            d->m_primaryInputType = Touch;
            d->m_availableInputTypes = Touch;
        } else if (screenType == "keyboard") {
            fixedInputType = true;
            d->m_primaryInputType = Keyboard;
            d->m_availableInputTypes = Keyboard;
        } else if (screenType == "remotecontrol") {
            fixedInputType = true;
            d->m_primaryInputType = RemoteControl;
            d->m_availableInputTypes = RemoteControl;
        }
    }



    if (!fixedInputType) {
        if (Kirigami::TabletModeWatcher::self()->isTabletModeAvailable()) {
            d->m_availableScreenTypes |= Tablet;
        }

        connect(Kirigami::TabletModeWatcher::self(), &Kirigami::TabletModeWatcher::tabletModeAvailableChanged, this, [this](bool tabletModeAvailable) {
            if (tabletModeAvailable) {
                d->addAvailableScreenType(Tablet);
            } else {
                d->removeAvailableScreenType(Tablet);
            }
        });

        if (Kirigami::TabletModeWatcher::self()->isTabletMode()) {
            d->m_screenType = Tablet;
            d->m_primaryInputType = Touch;
        }
        connect(Kirigami::TabletModeWatcher::self(), &Kirigami::TabletModeWatcher::tabletModeChanged, this, [this](bool tabletMode) {
            if (tabletMode) {
                if (d->m_screenType != Handheld) {
                    d->setScreenType(Tablet);
                }
                d->setPrimaryInputType(Touch);
            } else {
                d->setScreenType(Desktop);
                d->setPrimaryInputType(PointingDevice);
            }
        });
    }

    const auto touchDevices = QTouchDevice::devices();
    for (const auto &device : touchDevices) {
        if (device->type() == QTouchDevice::TouchScreen) {
            d->m_availableInputTypes |= Touch;
            break;
        }
    }

    if (d->m_window) {
        d->m_window->installEventFilter(this);
    } else {
        if (QGuiApplication::focusWindow()) {
            d->m_window = QGuiApplication::focusWindow();
            d->m_window->installEventFilter(this);
        }
        connect(qApp, &QGuiApplication::focusWindowChanged, this, [this](QWindow *win) {
            if (d->m_window) {
                d->m_window->removeEventFilter(this);
            }
            if (win) {
                d->m_window = win;
                win->installEventFilter(this);
            }
        });
    }

#endif
}

FormFactorInfo::~FormFactorInfo()
{
}

QWindow *FormFactorInfo::window() const
{
    return d->m_window;
}

FormFactorInfo::ScreenType FormFactorInfo::screenType() const
{
    return d->m_screenType;
}

FormFactorInfo::ScreenTypes FormFactorInfo::availableScreenTypes() const
{
    return d->m_availableScreenTypes;
}


FormFactorInfo::InputType FormFactorInfo::primaryInputType() const
{
    return d->m_primaryInputType;
}

FormFactorInfo::InputType FormFactorInfo::transientInputType() const
{
    return d->m_transientInputType;
}

FormFactorInfo::InputTypes FormFactorInfo::availableInputTypes() const
{
    return d->m_availableInputTypes;
}

bool FormFactorInfo::eventFilter(QObject *watched, QEvent *event)
{
    Q_UNUSED(watched)
    switch (event->type()) {
    case QEvent::TouchBegin:
        d->setTransientInputType(Touch);
        break;
    case QEvent::MouseButtonPress:
    case QEvent::MouseMove: {
        QMouseEvent *me = static_cast<QMouseEvent *>(event);
        if (me->source() == Qt::MouseEventNotSynthesized) {
            d->setTransientInputType(PointingDevice);
        }
        break;
    }
    case QEvent::Wheel:
        d->setTransientInputType(PointingDevice);
    default:
        break;
    }

    return false;
}

}

#include "moc_formfactorinfo.cpp"
