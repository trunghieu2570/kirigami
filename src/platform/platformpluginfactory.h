/*
 *  SPDX-FileCopyrightText: 2017 by Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#ifndef KIRIGAMI_KIRIGAMIPLUGINFACTORY_H
#define KIRIGAMI_KIRIGAMIPLUGINFACTORY_H

#include <QObject>

#include "kirigamiplatform_export.h"

class QQmlEngine;

namespace Kirigami
{
namespace Platform
{
class PlatformTheme;
class Units;

/**
 * @class KirigamiPluginFactory kirigamipluginfactory.h <Kirigami/KirigamiPluginFactory>
 *
 * This class is reimpleented by plugins to provide different implementations
 * of PlatformTheme
 */
class KIRIGAMIPLATFORM_EXPORT PlatformPluginFactory : public QObject
{
    Q_OBJECT

public:
    explicit KirigamiPluginFactory(QObject *parent = nullptr);
    ~KirigamiPluginFactory() override;

    /**
     * Creates an instance of PlatformTheme which can come out from
     * an implementation provided by a plugin
     *
     * If this returns nullptr the PlatformTheme will use a fallback
     * implementation that loads a theme definition from a QML file.
     *
     * @param parent the parent object of the created PlatformTheme
     */
    virtual PlatformTheme *createPlatformTheme(QObject *parent) = 0;

    /**
     * Creates an instance of Units which can come from an implementation
     * provided by a plugin
     * @param parent the parent of the units object
     */
    virtual Units *createUnits(QObject *parent) = 0;

    /**
     * finds the plugin providing units and platformtheme for the current style
     * The plugin pointer is cached, so only the first call is a potentially heavy operation
     * @param pluginName The name we want to search for, if empty the name of
     *           the current QtQuickControls style will be searched
     * @return pointer to the KirigamiPluginFactory of the current style
     */
    static KirigamiPluginFactory *findPlugin(const QString &pluginName = {});
};

}
}

QT_BEGIN_NAMESPACE
#define KirigamiPluginFactory_iid "org.kde.kirigami.KirigamiPluginFactory"
Q_DECLARE_INTERFACE(Kirigami::KirigamiPluginFactory, KirigamiPluginFactory_iid)
QT_END_NAMESPACE

#endif // KIRIGAMIPLUGINFACTORY_H
