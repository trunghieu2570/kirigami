/*
 *  SPDX-FileCopyrightText: 2009 Alan Alpert <alan.alpert@nokia.com>
 *  SPDX-FileCopyrightText: 2010 Ménard Alexis <menard@kde.org>
 *  SPDX-FileCopyrightText: 2010 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#include "kirigamiplugin.h"
#include "colorutils.h"
#include "columnview.h"
#include "delegaterecycler.h"
#include "enums.h"
#include "formlayoutattached.h"
#include "headerfooterlayout.h"
#include "icon.h"
#include "imagecolors.h"
#include "inputmethod.h"
#include "mnemonicattached.h"
#include "overlayzstackingattached.h"
#include "pagepool.h"
#include "scenepositionattached.h"
#include "settings.h"
#include "shadowedrectangle.h"
#include "shadowedtexture.h"
#include "sizegroup.h"
#include "spellcheckattached.h"
#include "toolbarlayout.h"
#include "units.h"
#include "wheelhandler.h"

#include <QClipboard>
#include <QGuiApplication>
#if defined(Q_OS_ANDROID)
#include <QResource>
#endif
#include <QQmlContext>
#include <QQuickItem>
#include <QQuickStyle>

#include "libkirigami/basictheme_p.h"
#include "libkirigami/kirigamipluginfactory.h"
#include "libkirigami/platformtheme.h"
#include "libkirigami/styleselector_p.h"
#include "loggingcategory.h"

static QString s_selectedStyle;

#ifdef KIRIGAMI_BUILD_TYPE_STATIC
#include "loggingcategory.h"
#include <QDebug>
#endif

class CopyHelperPrivate : public QObject
{
    Q_OBJECT
public:
    Q_INVOKABLE static void copyTextToClipboard(const QString &text)
    {
        qGuiApp->clipboard()->setText(text);
    }
};

// we can't do this in the plugin object directly, as that can live in a different thread
// and event filters are only allowed in the same thread as the filtered object
class LanguageChangeEventFilter : public QObject
{
    Q_OBJECT
public:
    bool eventFilter(QObject *receiver, QEvent *event) override
    {
        if (event->type() == QEvent::LanguageChange && receiver == QCoreApplication::instance()) {
            Q_EMIT languageChangeEvent();
        }
        return QObject::eventFilter(receiver, event);
    }

Q_SIGNALS:
    void languageChangeEvent();
};

KirigamiPlugin::KirigamiPlugin(QObject *parent)
    : QQmlExtensionPlugin(parent)
{
    auto filter = new LanguageChangeEventFilter;
    filter->moveToThread(QCoreApplication::instance()->thread());
    QCoreApplication::instance()->installEventFilter(filter);
    connect(filter, &LanguageChangeEventFilter::languageChangeEvent, this, &KirigamiPlugin::languageChangeEvent);
}

QUrl KirigamiPlugin::componentUrl(const QString &fileName) const
{
    return Kirigami::StyleSelector::componentUrl(fileName);
}

using SingletonCreationFunction = QObject *(*)(QQmlEngine *, QJSEngine *);

template<class T>
inline SingletonCreationFunction singleton()
{
    static_assert(std::is_base_of<QObject, T>::value);
    return [](QQmlEngine *engine, QJSEngine *) -> QObject * {
        auto x = new T;
        x->setParent(engine);
        return x;
    };
}

void KirigamiPlugin::registerTypes(const char *uri)
{
#if defined(Q_OS_ANDROID)
    QResource::registerResource(QStringLiteral("assets:/android_rcc_bundle.rcc"));
#endif

    Q_ASSERT(QLatin1String(uri) == QLatin1String("org.kde.kirigami"));

    Kirigami::StyleSelector::setBaseUrl(baseUrl());

    if (QIcon::themeName().isEmpty() && !qEnvironmentVariableIsSet("XDG_CURRENT_DESKTOP")) {
        QIcon::setThemeSearchPaths({Kirigami::StyleSelector::resolveFilePath(QStringLiteral(".")), QStringLiteral(":/icons")});
        QIcon::setThemeName(QStringLiteral("breeze-internal"));
    } else {
        QIcon::setFallbackSearchPaths(QIcon::fallbackSearchPaths() << Kirigami::StyleSelector::resolveFilePath(QStringLiteral("icons")));
    }

    qmlRegisterSingletonType<Settings>(uri, 2, 0, "Settings", [](QQmlEngine *e, QJSEngine *) -> QObject * {
        Settings *settings = Settings::self();
        // singleton managed internally, qml should never delete it
        e->setObjectOwnership(settings, QQmlEngine::CppOwnership);
        settings->setStyle(Kirigami::StyleSelector::style());
        return settings;
    });

    qmlRegisterUncreatableType<ApplicationHeaderStyle>(uri,
                                                       2,
                                                       0,
                                                       "ApplicationHeaderStyle",
                                                       QStringLiteral("Cannot create objects of type ApplicationHeaderStyle"));

    qmlRegisterSingletonType<Kirigami::Units>(uri, 2, 0, "Units", [](QQmlEngine *engine, QJSEngine *) {
#ifndef KIRIGAMI_BUILD_TYPE_STATIC
        auto plugin = Kirigami::KirigamiPluginFactory::findPlugin();
        if (plugin) {
            return plugin->createUnits(engine);
        } else {
            qWarning(KirigamiLog) << "Failed to find a Kirigami platform plugin";
        }
#endif
        // Fall back to the default units implementation
        return new Kirigami::Units(engine);
    });

    qmlRegisterRevision<QQuickItem, 6>(uri, 2, 0);
    qmlRegisterType(componentUrl(QStringLiteral("Action.qml")), uri, 2, 0, "Action");
    qmlRegisterType(componentUrl(QStringLiteral("AbstractApplicationHeader.qml")), uri, 2, 0, "AbstractApplicationHeader");
    qmlRegisterType(componentUrl(QStringLiteral("AbstractApplicationWindow.qml")), uri, 2, 0, "AbstractApplicationWindow");
    qmlRegisterType(componentUrl(QStringLiteral("AbstractListItem.qml")), uri, 2, 0, "AbstractListItem");
    qmlRegisterType(componentUrl(QStringLiteral("ApplicationWindow.qml")), uri, 2, 0, "ApplicationWindow");
    qmlRegisterType(componentUrl(QStringLiteral("BasicListItem.qml")), uri, 2, 0, "BasicListItem");
    qmlRegisterType(componentUrl(QStringLiteral("OverlayDrawer.qml")), uri, 2, 0, "OverlayDrawer");
    qmlRegisterType(componentUrl(QStringLiteral("ContextDrawer.qml")), uri, 2, 0, "ContextDrawer");
    qmlRegisterType(componentUrl(QStringLiteral("GlobalDrawer.qml")), uri, 2, 0, "GlobalDrawer");
    qmlRegisterType(componentUrl(QStringLiteral("Heading.qml")), uri, 2, 0, "Heading");
    qmlRegisterType(componentUrl(QStringLiteral("Separator.qml")), uri, 2, 0, "Separator");
    qmlRegisterType(componentUrl(QStringLiteral("PageRow.qml")), uri, 2, 0, "PageRow");

    qmlRegisterType<Icon>(uri, 2, 0, "Icon");

    qmlRegisterType(componentUrl(QStringLiteral("OverlaySheet.qml")), uri, 2, 0, "OverlaySheet");
    qmlRegisterType(componentUrl(QStringLiteral("Page.qml")), uri, 2, 0, "Page");
    qmlRegisterType(componentUrl(QStringLiteral("ScrollablePage.qml")), uri, 2, 0, "ScrollablePage");
    qmlRegisterType(componentUrl(QStringLiteral("SwipeListItem.qml")), uri, 2, 0, "SwipeListItem");

    // 2.1
    qmlRegisterType(componentUrl(QStringLiteral("AbstractApplicationItem.qml")), uri, 2, 1, "AbstractApplicationItem");
    qmlRegisterType(componentUrl(QStringLiteral("ApplicationItem.qml")), uri, 2, 1, "ApplicationItem");

    // 2.2
    // Theme changed from a singleton to an attached property
    qmlRegisterUncreatableType<Kirigami::PlatformTheme>(uri,
                                                        2,
                                                        2,
                                                        "Theme",
                                                        QStringLiteral("Cannot create objects of type Theme, use it as an attached property"));

    // 2.3
    qmlRegisterType(componentUrl(QStringLiteral("FormLayout.qml")), uri, 2, 3, "FormLayout");
    qmlRegisterUncreatableType<FormLayoutAttached>(uri,
                                                   2,
                                                   3,
                                                   "FormData",
                                                   QStringLiteral("Cannot create objects of type FormData, use it as an attached property"));
    qmlRegisterUncreatableType<MnemonicAttached>(uri,
                                                 2,
                                                 3,
                                                 "MnemonicData",
                                                 QStringLiteral("Cannot create objects of type MnemonicData, use it as an attached property"));

    // 2.4
    qmlRegisterType(componentUrl(QStringLiteral("AbstractCard.qml")), uri, 2, 4, "AbstractCard");
    qmlRegisterType(componentUrl(QStringLiteral("Card.qml")), uri, 2, 4, "Card");
    qmlRegisterType(componentUrl(QStringLiteral("CardsListView.qml")), uri, 2, 4, "CardsListView");
    qmlRegisterType(componentUrl(QStringLiteral("CardsGridView.qml")), uri, 2, 4, "CardsGridView");
    qmlRegisterType(componentUrl(QStringLiteral("CardsLayout.qml")), uri, 2, 4, "CardsLayout");
    qmlRegisterType(componentUrl(QStringLiteral("InlineMessage.qml")), uri, 2, 4, "InlineMessage");
    qmlRegisterUncreatableType<MessageType>(uri, 2, 4, "MessageType", QStringLiteral("Cannot create objects of type MessageType"));
    qmlRegisterType<DelegateRecycler>(uri, 2, 4, "DelegateRecycler");

    // 2.5
    qmlRegisterType(componentUrl(QStringLiteral("ListItemDragHandle.qml")), uri, 2, 5, "ListItemDragHandle");
    qmlRegisterType(componentUrl(QStringLiteral("ActionToolBar.qml")), uri, 2, 5, "ActionToolBar");
    qmlRegisterUncreatableType<ScenePositionAttached>(uri,
                                                      2,
                                                      5,
                                                      "ScenePosition",
                                                      QStringLiteral("Cannot create objects of type ScenePosition, use it as an attached property"));

    // 2.6
    qmlRegisterType(componentUrl(QStringLiteral("AboutPage.qml")), uri, 2, 6, "AboutPage");
    qmlRegisterType(componentUrl(QStringLiteral("LinkButton.qml")), uri, 2, 6, "LinkButton");
    qmlRegisterType(componentUrl(QStringLiteral("UrlButton.qml")), uri, 2, 6, "UrlButton");
    qmlRegisterSingletonType<CopyHelperPrivate>("org.kde.kirigami.private", 2, 6, "CopyHelperPrivate", singleton<CopyHelperPrivate>());

    // 2.7
    qmlRegisterType<ColumnView>(uri, 2, 7, "ColumnView");
    qmlRegisterType(componentUrl(QStringLiteral("ActionTextField.qml")), uri, 2, 7, "ActionTextField");

    // 2.8
    qmlRegisterType(componentUrl(QStringLiteral("SearchField.qml")), uri, 2, 8, "SearchField");
    qmlRegisterType(componentUrl(QStringLiteral("PasswordField.qml")), uri, 2, 8, "PasswordField");

    // 2.9
    qmlRegisterType<WheelHandler>(uri, 2, 9, "WheelHandler");
    qmlRegisterUncreatableType<KirigamiWheelEvent>(uri, 2, 9, "WheelEvent", QStringLiteral("Cannot create objects of type WheelEvent."));

    // 2.10
    qmlRegisterType(componentUrl(QStringLiteral("ListSectionHeader.qml")), uri, 2, 10, "ListSectionHeader");

    // 2.11
    qmlRegisterType<PagePool>(uri, 2, 11, "PagePool");
    qmlRegisterType(componentUrl(QStringLiteral("PagePoolAction.qml")), uri, 2, 11, "PagePoolAction");

    // 2.12
    qmlRegisterType<ShadowedRectangle>(uri, 2, 12, "ShadowedRectangle");
    qmlRegisterType<ShadowedTexture>(uri, 2, 12, "ShadowedTexture");
    qmlRegisterType(componentUrl(QStringLiteral("ShadowedImage.qml")), uri, 2, 12, "ShadowedImage");
    qmlRegisterType(componentUrl(QStringLiteral("PlaceholderMessage.qml")), uri, 2, 12, "PlaceholderMessage");

    qmlRegisterUncreatableType<BorderGroup>(uri, 2, 12, "BorderGroup", QStringLiteral("Used as grouped property"));
    qmlRegisterUncreatableType<ShadowGroup>(uri, 2, 12, "ShadowGroup", QStringLiteral("Used as grouped property"));
    qmlRegisterSingletonType<ColorUtils>(uri, 2, 12, "ColorUtils", singleton<ColorUtils>());

    qmlRegisterUncreatableType<CornersGroup>(uri, 2, 12, "CornersGroup", QStringLiteral("Used as grouped property"));

    // 2.13
    qmlRegisterType<ImageColors>(uri, 2, 13, "ImageColors");

    // 2.14
    qmlRegisterType(componentUrl(QStringLiteral("FlexColumn.qml")), uri, 2, 14, "FlexColumn");
    qmlRegisterType<ToolBarLayout>(uri, 2, 14, "ToolBarLayout");
    qmlRegisterSingletonType<DisplayHint>(uri, 2, 14, "DisplayHint", singleton<DisplayHint>());
    qmlRegisterType<SizeGroup>(uri, 2, 14, "SizeGroup");
    qmlRegisterType(componentUrl(QStringLiteral("CheckableListItem.qml")), uri, 2, 14, "CheckableListItem");

    // 2.16
    qmlRegisterType<Kirigami::BasicThemeDefinition>(uri, 2, 16, "BasicThemeDefinition");

    // 2.18
    qmlRegisterUncreatableType<SpellCheckAttached>(uri,
                                                   2,
                                                   18,
                                                   "SpellCheck",
                                                   QStringLiteral("Cannot create objects of type SpellCheck, use it as an attached property"));

    // 2.19
    qmlRegisterType(componentUrl(QStringLiteral("AboutItem.qml")), uri, 2, 19, "AboutItem");
    qmlRegisterType(componentUrl(QStringLiteral("NavigationTabBar.qml")), uri, 2, 19, "NavigationTabBar");
    qmlRegisterType(componentUrl(QStringLiteral("NavigationTabButton.qml")), uri, 2, 19, "NavigationTabButton");
    qmlRegisterType(componentUrl(QStringLiteral("Dialog.qml")), uri, 2, 19, "Dialog");
    qmlRegisterType(componentUrl(QStringLiteral("MenuDialog.qml")), uri, 2, 19, "MenuDialog");
    qmlRegisterType(componentUrl(QStringLiteral("PromptDialog.qml")), uri, 2, 19, "PromptDialog");
    qmlRegisterType(componentUrl(QStringLiteral("Chip.qml")), uri, 2, 19, "Chip");
    qmlRegisterType(componentUrl(QStringLiteral("LoadingPlaceholder.qml")), uri, 2, 19, "LoadingPlaceholder");

    qmlRegisterSingletonType<InputMethod>(uri, 2, 19, "InputMethod", [](QQmlEngine *, QJSEngine *) {
        return new InputMethod{};
    });

    // 2.20
    qmlRegisterType(componentUrl(QStringLiteral("SelectableLabel.qml")), uri, 2, 20, "SelectableLabel");
    qmlRegisterUncreatableType<OverlayZStackingAttached>(uri,
                                                         2,
                                                         20,
                                                         "OverlayZStacking",
                                                         QStringLiteral("Cannot create objects of type OverlayZStacking, use it as an attached property"));
    qmlRegisterType(componentUrl(QStringLiteral("InlineViewHeader.qml")), uri, 2, 20, "InlineViewHeader");

    qmlRegisterType<HeaderFooterLayout>(uri, 2, 20, "HeaderFooterLayout");

    qmlProtectModule(uri, 2);
}

void KirigamiPlugin::initializeEngine(QQmlEngine *engine, const char *uri)
{
    Q_UNUSED(uri);
    connect(this, &KirigamiPlugin::languageChangeEvent, engine, &QQmlEngine::retranslate);
}

#ifdef KIRIGAMI_BUILD_TYPE_STATIC
KirigamiPlugin &KirigamiPlugin::getInstance()
{
    static KirigamiPlugin instance;
    return instance;
}

void KirigamiPlugin::registerTypes(QQmlEngine *engine)
{
    if (engine) {
        engine->addImportPath(QLatin1String(":/"));
    } else {
        qCWarning(KirigamiLog)
            << "Registering Kirigami on a null QQmlEngine instance - you likely want to pass a valid engine, or you will want to manually add the "
               "qrc root path :/ to your import paths list so the engine is able to load the plugin";
    }
}
#endif

#include "kirigamiplugin.moc"
#include "moc_kirigamiplugin.cpp"
