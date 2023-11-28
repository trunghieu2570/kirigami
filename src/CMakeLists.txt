include(${CMAKE_CURRENT_SOURCE_DIR}/IncludeStaticDependencies.cmake)

add_subdirectory(platform)

add_subdirectory(delegates)

add_library(Kirigami)
add_library(KF6::Kirigami ALIAS Kirigami)

if (WIN32)
    # Kirigami apparently adds too many sources so on Windows we end
    # up running into command line length limits. So disable cache
    # generation on Windows for now.
    set(_extra_options NO_CACHEGEN)
endif()
if (BUILD_SHARED_LIBS)
    set(_extra_options ${_extra_options} NO_PLUGIN_OPTIONAL)
endif()
if (ANDROID)
    set(_extra_options ${_extra_options} OPTIONAL_IMPORTS org.kde.breeze)
endif()

ecm_add_qml_module(Kirigami URI "org.kde.kirigami" VERSION 2.0
    CLASS_NAME KirigamiPlugin
    DEPENDENCIES
    "QtQuick.Controls"
    "Qt5Compat.GraphicalEffects"
    IMPORTS
    "org.kde.kirigami.platform"
    "org.kde.kirigami.delegates"
    ${_extra_options}
)

ecm_create_qm_loader(kirigami_QM_LOADER libkirigami6_qt)
target_sources(Kirigami PRIVATE ${kirigami_QM_LOADER})

ecm_qt_declare_logging_category(Kirigami
    HEADER loggingcategory.h
    IDENTIFIER KirigamiLog
    CATEGORY_NAME kf.kirigami
    DESCRIPTION "Kirigami"
    DEFAULT_SEVERITY Warning
    EXPORT KIRIGAMI
)

set_target_properties(Kirigami PROPERTIES
    VERSION     ${PROJECT_VERSION}
    SOVERSION   6
    EXPORT_NAME "Kirigami"
)

target_include_directories(Kirigami PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/platform
    ${CMAKE_CURRENT_BINARY_DIR}/platform
)

target_sources(Kirigami PRIVATE
    colorutils.cpp
    colorutils.h
    columnview.cpp
    columnview.h
    columnview_p.h
    enums.cpp
    enums.h
    formlayoutattached.cpp
    formlayoutattached.h
    headerfooterlayout.cpp
    icon.cpp
    icon.h
    imagecolors.cpp
    imagecolors.h
    mnemonicattached.cpp
    mnemonicattached.h
    overlayzstackingattached.cpp
    overlayzstackingattached.h
    padding.cpp
    padding.h
    pagepool.cpp
    pagepool.h
    scenepositionattached.cpp
    scenepositionattached.h
    shadowedrectangle.cpp
    shadowedrectangle.h
    shadowedtexture.cpp
    shadowedtexture.h
    sizegroup.cpp
    sizegroup.h
    spellcheckattached.cpp
    spellcheckattached.h
    toolbarlayout.cpp
    toolbarlayoutdelegate.cpp
    toolbarlayoutdelegate.h
    toolbarlayout.h
    wheelhandler.cpp
    wheelhandler.h

    scenegraph/managedtexturenode.cpp
    scenegraph/managedtexturenode.h
    scenegraph/paintedrectangleitem.cpp
    scenegraph/paintedrectangleitem.h
    scenegraph/shadowedborderrectanglematerial.cpp
    scenegraph/shadowedborderrectanglematerial.h
    scenegraph/shadowedbordertexturematerial.cpp
    scenegraph/shadowedbordertexturematerial.h
    scenegraph/shadowedrectanglematerial.cpp
    scenegraph/shadowedrectanglematerial.h
    scenegraph/shadowedrectanglenode.cpp
    scenegraph/shadowedrectanglenode.h
    scenegraph/shadowedtexturematerial.cpp
    scenegraph/shadowedtexturematerial.h
    scenegraph/shadowedtexturenode.cpp
    scenegraph/shadowedtexturenode.h
)

target_sources(Kirigamiplugin PRIVATE
    kirigamiplugin.cpp
    kirigamiplugin.h
)

qt6_add_shaders(Kirigami "shaders"
    BATCHABLE
    PRECOMPILE
    OPTIMIZED
    PREFIX "/org/kde/kirigami/shaders"
    FILES
        scenegraph/shaders6/shadowedrectangle.vert
        scenegraph/shaders6/shadowedrectangle.frag
        scenegraph/shaders6/shadowedrectangle_lowpower.frag
        scenegraph/shaders6/shadowedborderrectangle.frag
        scenegraph/shaders6/shadowedborderrectangle_lowpower.frag
        scenegraph/shaders6/shadowedtexture.frag
        scenegraph/shaders6/shadowedtexture_lowpower.frag
        scenegraph/shaders6/shadowedbordertexture.frag
        scenegraph/shaders6/shadowedbordertexture_lowpower.frag
    OUTPUTS
        shadowedrectangle.vert.qsb
        shadowedrectangle.frag.qsb
        shadowedrectangle_lowpower.frag.qsb
        shadowedborderrectangle.frag.qsb
        shadowedborderrectangle_lowpower.frag.qsb
        shadowedtexture.frag.qsb
        shadowedtexture_lowpower.frag.qsb
        shadowedbordertexture.frag.qsb
        shadowedbordertexture_lowpower.frag.qsb
)

ecm_target_qml_sources(Kirigami SOURCES
    controls/Action.qml
    controls/AbstractApplicationHeader.qml
    controls/AbstractApplicationWindow.qml
    controls/ApplicationWindow.qml
    controls/OverlayDrawer.qml
    controls/ContextDrawer.qml
    controls/GlobalDrawer.qml
    controls/Heading.qml
    controls/Separator.qml
    controls/PageRow.qml
    controls/OverlaySheet.qml
    controls/Page.qml
    controls/ScrollablePage.qml
    controls/SwipeListItem.qml
)

ecm_target_qml_sources(Kirigami VERSION 2.1 SOURCES
    controls/AbstractApplicationItem.qml
    controls/ApplicationItem.qml
)

ecm_target_qml_sources(Kirigami VERSION 2.3 SOURCES
    controls/FormLayout.qml
)

ecm_target_qml_sources(Kirigami VERSION 2.4 SOURCES
    controls/AbstractCard.qml
    controls/Card.qml
    controls/CardsListView.qml
    controls/CardsLayout.qml
    controls/InlineMessage.qml
)

ecm_target_qml_sources(Kirigami VERSION 2.5 SOURCES
    controls/ListItemDragHandle.qml
    controls/ActionToolBar.qml
)

ecm_target_qml_sources(Kirigami VERSION 2.6 SOURCES
    controls/AboutPage.qml
    controls/LinkButton.qml
    controls/UrlButton.qml
)

ecm_target_qml_sources(Kirigami VERSION 2.7 SOURCES
    controls/ActionTextField.qml
)

ecm_target_qml_sources(Kirigami VERSION 2.8 SOURCES
    controls/SearchField.qml
    controls/PasswordField.qml
)

ecm_target_qml_sources(Kirigami VERSION 2.10 SOURCES
    controls/ListSectionHeader.qml
)

ecm_target_qml_sources(Kirigami VERSION 2.11 SOURCES
    controls/PagePoolAction.qml
)

ecm_target_qml_sources(Kirigami VERSION 2.12 SOURCES
    controls/ShadowedImage.qml
    controls/PlaceholderMessage.qml
)

ecm_target_qml_sources(Kirigami VERSION 2.14 SOURCES
    controls/FlexColumn.qml
)

ecm_target_qml_sources(Kirigami VERSION 2.19 SOURCES
    controls/AboutItem.qml
    controls/NavigationTabBar.qml
    controls/NavigationTabButton.qml
    controls/Dialog.qml
    controls/MenuDialog.qml
    controls/PromptDialog.qml
    controls/Chip.qml
    controls/LoadingPlaceholder.qml
)

ecm_target_qml_sources(Kirigami VERSION 2.20 SOURCES
    controls/SelectableLabel.qml
    controls/InlineViewHeader.qml
)

ecm_target_qml_sources(Kirigami PRIVATE PATH private SOURCES
    controls/private/ActionIconGroup.qml
    controls/private/ActionMenuItem.qml
    controls/private/ActionsMenu.qml
    controls/private/BannerImage.qml
    controls/private/ContextDrawerActionItem.qml
    controls/private/CornerShadow.qml
    controls/private/DefaultCardBackground.qml
    controls/private/DefaultChipBackground.qml
    controls/private/DefaultPageTitleDelegate.qml
    controls/private/EdgeShadow.qml
    controls/private/GlobalDrawerActionItem.qml
    controls/private/MobileDialogLayer.qml
    controls/private/PrivateActionToolButton.qml
    controls/private/SwipeItemEventFilter.qml
)

ecm_target_qml_sources(Kirigami PRIVATE PATH private/globaltoolbar SOURCES
    controls/private/globaltoolbar/AbstractPageHeader.qml
    controls/private/globaltoolbar/BreadcrumbControl.qml
    controls/private/globaltoolbar/PageRowGlobalToolBarStyleGroup.qml
    controls/private/globaltoolbar/PageRowGlobalToolBarUI.qml
    controls/private/globaltoolbar/TitlesPageHeader.qml
    controls/private/globaltoolbar/ToolBarPageHeader.qml
    controls/private/globaltoolbar/ToolBarPageFooter.qml
)

ecm_target_qml_sources(Kirigami PRIVATE PATH templates SOURCES
    controls/templates/AbstractApplicationHeader.qml
    controls/templates/AbstractCard.qml
    controls/templates/Chip.qml
    controls/templates/InlineMessage.qml
    controls/templates/OverlayDrawer.qml
    controls/templates/OverlaySheet.qml
    controls/templates/SingletonHeaderSizeGroup.qml
    controls/templates/qmldir
)

ecm_target_qml_sources(Kirigami PRIVATE PATH templates/private SOURCES
    controls/templates/private/BackButton.qml
    controls/templates/private/BorderPropertiesGroup.qml
    controls/templates/private/ContextIcon.qml
    controls/templates/private/DrawerHandle.qml
    controls/templates/private/ForwardButton.qml
    controls/templates/private/GenericDrawerIcon.qml
    controls/templates/private/IconPropertiesGroup.qml
    controls/templates/private/MenuIcon.qml
    controls/templates/private/PassiveNotificationsManager.qml
    controls/templates/private/qmldir
)

qt_target_qml_sources(Kirigami RESOURCES
    styles/Material/InlineMessage.qml
    styles/Material/Theme.qml
)

if (DESKTOP_ENABLED)
    qt_target_qml_sources(Kirigami RESOURCES
        styles/org.kde.desktop/AbstractApplicationHeader.qml
        styles/org.kde.desktop/Theme.qml
    )
endif()

include_static_dependencies(Kirigami EXPORT KirigamiTargets)

target_link_libraries(Kirigami
    PUBLIC
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
    PRIVATE
    Qt6::Concurrent
    ${Kirigami_EXTRA_LIBS}
)

if (HAVE_OpenMP)
    target_link_libraries(Kirigami PRIVATE OpenMP::OpenMP_CXX)
endif()

if (NOT BUILD_SHARED_LIBS)
    # Ensure we install the plugin library file as that's required to link
    # against for static builds to work properly
    target_link_libraries(Kirigamiplugin PRIVATE KirigamiPlatformplugin KirigamiDelegatesplugin)
    install(TARGETS Kirigamiplugin EXPORT KirigamiTargets ${KF_INSTALL_TARGETS_DEFAULT_ARGS})
else()
    target_link_libraries(Kirigami PUBLIC KirigamiPlatform PRIVATE KirigamiDelegates)
endif()

install(TARGETS Kirigami EXPORT KirigamiTargets ${KF_INSTALL_TARGETS_DEFAULT_ARGS})
install(EXPORT KirigamiTargets
    DESTINATION ${KDE_INSTALL_CMAKEPACKAGEDIR}/KF6Kirigami
    FILE KF6KirigamiTargets.cmake
    NAMESPACE KF6
)

ecm_finalize_qml_module(Kirigami DESTINATION ${KDE_INSTALL_QMLDIR})

ecm_add_qml_module(KirigamiPrivatePlugin URI org.kde.kirigami.private VERSION 2.6 GENERATE_PLUGIN_SOURCE)

target_sources(KirigamiPrivatePlugin PRIVATE copyhelper.cpp)

target_link_libraries(KirigamiPrivatePlugin PRIVATE Qt6::Gui)

ecm_finalize_qml_module(KirigamiPrivatePlugin DESTINATION ${KDE_INSTALL_QMLDIR})


if (ANDROID)
    install(FILES Kirigami-android-dependencies.xml
        DESTINATION ${KDE_INSTALL_LIBDIR}
        RENAME Kirigami_${CMAKE_ANDROID_ARCH_ABI}-android-dependencies.xml
    )
endif()
