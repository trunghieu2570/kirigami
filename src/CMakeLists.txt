
add_subdirectory(libkirigami)

ecm_add_qml_module(KirigamiPlugin URI "org.kde.kirigami" VERSION 2.0
    CLASS_NAME KirigamiPlugin
    DEPENDENCIES
    "QtQuick.Controls"
    "Qt5Compat.GraphicalEffects"
)

ecm_create_qm_loader(kirigami_QM_LOADER libkirigami6_qt)
target_sources(KirigamiPlugin PRIVATE ${kirigami_QM_LOADER})

target_include_directories(KirigamiPlugin PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/libkirigami
    ${CMAKE_CURRENT_BINARY_DIR}/libkirigami
)

target_sources(KirigamiPlugin PRIVATE
    colorutils.cpp
    colorutils.h
    columnview.cpp
    columnview.h
    columnview_p.h
    delegaterecycler.cpp
    delegaterecycler.h
    enums.cpp
    enums.h
    formlayoutattached.cpp
    formlayoutattached.h
    icon.cpp
    icon.h
    imagecolors.cpp
    imagecolors.h
    kirigamiplugin.cpp
    kirigamiplugin.h
    mnemonicattached.cpp
    mnemonicattached.h
    pagepool.cpp
    pagepool.h
    scenepositionattached.cpp
    scenepositionattached.h
    settings.cpp
    settings.h
    shadowedrectangle.cpp
    shadowedrectangle.h
    shadowedtexture.cpp
    shadowedtexture.h
    sizegroup.cpp
    sizegroup.h
    spellcheckinghint.cpp
    spellcheckinghint.h
    toolbarlayout.cpp
    toolbarlayoutdelegate.cpp
    toolbarlayoutdelegate.h
    toolbarlayout.h
    wheelhandler.cpp
    wheelhandler.h
    inputmethod.cpp

    scenegraph/managedtexturenode.cpp
    scenegraph/managedtexturenode.h
    scenegraph/paintedrectangleitem.cpp
    scenegraph/paintedrectangleitem.h
    ${CMAKE_CURRENT_BINARY_DIR}/libkirigami/loggingcategory.cpp
)
if (HAVE_QTGUI_OPENGL AND NOT KF6_PORTING_TODO)
    target_sources(KirigamiPlugin PRIVATE
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
endif()

qt6_add_shaders(KirigamiPlugin "shaders6"
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

ecm_target_qml_sources(KirigamiPlugin SOURCES
    controls/Action.qml
    controls/AbstractApplicationHeader.qml
    controls/AbstractApplicationWindow.qml
    controls/AbstractListItem.qml
    controls/ApplicationWindow.qml
    controls/BasicListItem.qml
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
    controls/AbstractApplicationItem.qml
    controls/ApplicationItem.qml
    controls/FormLayout.qml
    controls/AbstractCard.qml
    controls/Card.qml
    controls/CardsListView.qml
    controls/CardsGridView.qml
    controls/CardsLayout.qml
    controls/InlineMessage.qml
    controls/ListItemDragHandle.qml
    controls/ActionToolBar.qml
    controls/AboutPage.qml
    controls/LinkButton.qml
    controls/UrlButton.qml
    controls/ActionTextField.qml
    controls/SearchField.qml
    controls/PasswordField.qml
    controls/ListSectionHeader.qml
    controls/PagePoolAction.qml
    controls/ShadowedImage.qml
    controls/PlaceholderMessage.qml
    controls/FlexColumn.qml
    controls/CheckableListItem.qml
    controls/settingscomponents/CategorizedSettings.qml
    controls/settingscomponents/SettingAction.qml
    controls/AboutItem.qml
    controls/NavigationTabBar.qml
    # controls/NavigationTabButton.qml
    # controls/Dialog.qml
    # controls/MenuDialog.qml
    # controls/Chip.qml
    # controls/PromptDialog.qml
    # controls/LoadingPlaceholder.qml
    # controls/SelectableLabel.qml
    # controls/private/ActionButton.qml
    # controls/private/ActionIconGroup.qml
    # controls/private/ActionMenuItem.qml
    # controls/private/ActionsMenu.qml
    # controls/private/BannerImage.qml
    # controls/private/CardsGridViewPrivate.qml
    # controls/private/CornerShadow.qml
    # controls/private/DefaultCardBackground.qml
    # controls/private/ContextDrawerActionItem.qml
    # controls/private/DefaultChipBackground.qml
    # controls/private/DefaultPageTitleDelegate.qml
    # controls/private/GlobalDrawerActionItem.qml
    # controls/private/PrivateActionToolButton.qml
    # controls/private/EdgeShadow.qml
    # controls/private/SwipeItemEventFilter.qml
    # controls/private/globaltoolbar/AbstractPageHeader.qml
    # controls/private/globaltoolbar/BreadcrumbControl.qml
    # controls/private/globaltoolbar/PageRowGlobalToolBarStyleGroup.qml
    # controls/private/globaltoolbar/PageRowGlobalToolBarUI.qml
    # controls/private/globaltoolbar/TitlesPageHeader.qml
    # controls/private/globaltoolbar/ToolBarPageHeader.qml
    # controls/templates/AbstractApplicationHeader.qml
    # controls/templates/AbstractCard.qml
    # controls/templates/Chip.qml
    # controls/templates/InlineMessage.qml
    # controls/templates/OverlayDrawer.qml
    # controls/templates/OverlaySheet.qml
    # controls/templates/SingletonHeaderSizeGroup.qml
    # controls/templates/qmldir
    # controls/templates/private/BackButton.qml
    # controls/templates/private/BorderPropertiesGroup.qml
    # controls/templates/private/ContextIcon.qml
    # controls/templates/private/ForwardButton.qml
    # controls/templates/private/GenericDrawerIcon.qml
    # controls/templates/private/IconPropertiesGroup.qml
    # controls/templates/private/MenuIcon.qml
    # controls/templates/private/PassiveNotificationsManager.qml
)

qt_target_qml_sources(KirigamiPlugin RESOURCES
    styles/Material/InlineMessage.qml
    styles/Material/Theme.qml
)

if (DESKTOP_ENABLED)
    qt_target_qml_sources(KirigamiPlugin RESOURCES
        styles/org.kde.desktop/AbstractApplicationHeader.qml
        styles/org.kde.desktop/Theme.qml
    )
endif()

target_link_libraries(KirigamiPlugin
    PUBLIC Qt6::Core
    PRIVATE
    ${Kirigami_EXTRA_LIBS}
    Qt6::GuiPrivate
    Qt6::Qml
    Qt6::Quick
    Qt6::QuickControls2
    Qt6::Concurrent
    KF6Kirigami2
)

if (HAVE_OpenMP)
target_link_libraries(KirigamiPlugin PRIVATE OpenMP::OpenMP_CXX)
endif()

ecm_finalize_qml_module(KirigamiPlugin DESTINATION ${KDE_INSTALL_QMLDIR})

if (ANDROID)
    install(FILES KF6Kirigami2-android-dependencies.xml
        DESTINATION ${KDE_INSTALL_LIBDIR}
        RENAME KF6Kirigami2_${CMAKE_ANDROID_ARCH_ABI}-android-dependencies.xml
    )
endif()
