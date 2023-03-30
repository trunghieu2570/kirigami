/*
 *  SPDX-FileCopyrightText: 2018 Marco Martin <mart@kde.org>
 *  SPDX-FileCopyrightText: 2023 Harald Sitter <sitter@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#include "tabletmodewatcher.h"
#include <QCoreApplication>

#if defined(KIRIGAMI_ENABLE_DBUS)
#include "settings_impl_interface.h"
#include "settings_interface.h"
#include <QDBusConnection>
#endif

using namespace Qt::Literals::StringLiterals;

// TODO: All the dbus stuff should be conditional, optional win32 support

namespace Kirigami
{
KIRIGAMI2_EXPORT QEvent::Type TabletModeChangedEvent::type = QEvent::None;

class TabletModeWatcherSingleton
{
public:
    TabletModeWatcher self;
};

Q_GLOBAL_STATIC(TabletModeWatcherSingleton, privateTabletModeWatcherSelf)

class TabletModeWatcherPrivate
{
    static constexpr auto PORTAL_GROUP = "org.kde.TabletMode"_L1;
    static constexpr auto KEY_AVAILABLE = "available"_L1;
    static constexpr auto KEY_ENABLED = "enabled"_L1;

    static constexpr auto KDE_PORTAL_SERVICE_NAME = "org.freedesktop.impl.portal.desktop.kde"_L1;

public:
    template<typename DBusIface>
    void setupDBus(const QString &serviceName)
    {
        qDBusRegisterMetaType<VariantMapMap>();

        auto portal = new DBusIface(serviceName, u"/org/freedesktop/portal/desktop"_s, QDBusConnection::sessionBus(), q);
        if (const auto reply = portal->ReadAll({PORTAL_GROUP}); !reply.isError() && !reply.value().isEmpty()) {
            const auto properties = reply.value().value(PORTAL_GROUP);
            isTabletModeAvailable = properties[KEY_AVAILABLE].toBool();
            isTabletMode = properties[KEY_ENABLED].toBool();
            QObject::connect(portal, &DBusIface::SettingChanged, q, [this](const QString &group, const QString &key, const QDBusVariant &value) {
                if (group != PORTAL_GROUP) {
                    return;
                }
                if (key == KEY_AVAILABLE) {
                    isTabletModeAvailable = value.variant().toBool();
                    Q_EMIT q->tabletModeAvailableChanged(isTabletModeAvailable);
                } else if (key == KEY_ENABLED) {
                    setIsTablet(value.variant().toBool());
                }
            });
        } else {
            if (reply.isError()) {
                qWarning() << reply.error();
            }
            isTabletModeAvailable = false;
            isTabletMode = false;
        }
    }

    TabletModeWatcherPrivate(TabletModeWatcher *watcher)
        : q(watcher)
    {
        // Called here to avoid collisions with application event types so we should use
        // registerEventType for generating the event types.
        TabletModeChangedEvent::type = QEvent::Type(QEvent::registerEventType());
#if !defined(KIRIGAMI_ENABLE_DBUS) && (defined(Q_OS_ANDROID) || defined(Q_OS_IOS))
        isTabletModeAvailable = true;
        isTabletMode = true;
#elif defined(KIRIGAMI_ENABLE_DBUS)
        // Mostly for debug purposes and for platforms which are always mobile,
        // such as Plasma Mobile
        if (qEnvironmentVariableIsSet("QT_QUICK_CONTROLS_MOBILE") || qEnvironmentVariableIsSet("KDE_KIRIGAMI_TABLET_MODE")) {
            /* clang-format off */
            isTabletMode =
                (QString::fromLatin1(qgetenv("QT_QUICK_CONTROLS_MOBILE")) == QStringLiteral("1")
                    || QString::fromLatin1(qgetenv("QT_QUICK_CONTROLS_MOBILE")) == QStringLiteral("true"))
                    || (QString::fromLatin1(qgetenv("KDE_KIRIGAMI_TABLET_MODE")) == QStringLiteral("1")
                    || QString::fromLatin1(qgetenv("KDE_KIRIGAMI_TABLET_MODE")) == QStringLiteral("true"));
            /* clang-format on */
            isTabletModeAvailable = isTabletMode;
        } else {
            // A bit of awkward redirection... when kirigami is used by the portal service itself (e.g. for the
            // file open dialog) then we need to talk to the portal impl directly and let Qt handle the call
            // internally. Without this we'd be talking to the xdg-desktop-portal and that would talk to us again,
            // causing a deadlock until the dbus timeout is hit.
            if (QDBusConnection::sessionBus().interface()->servicePid(KDE_PORTAL_SERVICE_NAME) == qApp->applicationPid()){
                setupDBus<OrgFreedesktopImplPortalSettingsInterface>(KDE_PORTAL_SERVICE_NAME);
            } else {
                setupDBus<OrgFreedesktopPortalSettingsInterface>(u"org.freedesktop.portal.Desktop"_s);
            }
        }
// TODO: case for Windows
#else
        isTabletModeAvailable = false;
        isTabletMode = false;
#endif
    }
    ~TabletModeWatcherPrivate(){};
    void setIsTablet(bool tablet);

    TabletModeWatcher *q;
    QVector<QObject *> watchers;
    bool isTabletModeAvailable = false;
    bool isTabletMode = false;
};

void TabletModeWatcherPrivate::setIsTablet(bool tablet)
{
    if (isTabletMode == tablet) {
        return;
    }

    isTabletMode = tablet;
    TabletModeChangedEvent event{tablet};
    Q_EMIT q->tabletModeChanged(tablet);
    for (auto *w : watchers) {
        QCoreApplication::sendEvent(w, &event);
    }
}

TabletModeWatcher::TabletModeWatcher(QObject *parent)
    : QObject(parent)
    , d(new TabletModeWatcherPrivate(this))
{
}

TabletModeWatcher::~TabletModeWatcher()
{
    delete d;
}

TabletModeWatcher *TabletModeWatcher::self()
{
    return &privateTabletModeWatcherSelf()->self;
}

bool TabletModeWatcher::isTabletModeAvailable() const
{
    return d->isTabletModeAvailable;
}

bool TabletModeWatcher::isTabletMode() const
{
    return d->isTabletMode;
}

void TabletModeWatcher::addWatcher(QObject *watcher)
{
    d->watchers.append(watcher);
}

void TabletModeWatcher::removeWatcher(QObject *watcher)
{
    d->watchers.removeAll(watcher);
}
}

#include "moc_tabletmodewatcher.cpp"
