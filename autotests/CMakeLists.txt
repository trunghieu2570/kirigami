if(NOT TARGET Qt${QT_MAJOR_VERSION}::QuickTest)
    message(STATUS "Qt${QT_MAJOR_VERSION}QuickTest not found, autotests will not be built.")
    return()
endif()

include(ECMQmlTests)

ecm_create_qml_test_runner(
    HEADER_CODE "#ifdef STATIC_MODULE\n#include \"kirigamiplugin.h\"\nQ_IMPORT_PLUGIN(KirigamiPlugin)\n#endif"
    ENGINE_AVAILABLE_CODE "#ifdef STATIC_MODULE\nKirigamiPlugin::getInstance().registerTypes(engine);\n#endif"
)
if (NOT BUILD_SHARED_LIBS)
    target_compile_definitions(ecm_qml_test_runner PRIVATE STATIC_MODULE)
    target_link_libraries(ecm_qml_test_runner PRIVATE KirigamiPlugin)
endif()

ecm_add_qml_tests(TESTS
    tst_keynavigation.qml
    tst_listskeynavigation.qml
    tst_pagerow.qml
    tst_icon.qml
    tst_actiontoolbar.qml
    tst_pagerouter.qml
    tst_routerwindow.qml
    tst_avatar.qml
    tst_theme.qml
    tst_mnemonicdata.qml
    pagepool/tst_pagepool.qml
    pagepool/tst_layers.qml
    wheelhandler/tst_filterMouseEvents.qml
    wheelhandler/tst_invokables.qml
    wheelhandler/tst_onWheel.qml
    wheelhandler/tst_scrolling.qml
)

set_tests_properties(tst_theme.qml PROPERTIES
    ENVIRONMENT "QT_QUICK_CONTROLS_STYLE=default;KIRIGAMI_FORCE_STYLE=1"
)

# Simple instantiation tests to make sure all items work correctly.
# Don't add any items that are already handled by more comprehensive tests above.
# Also, some items implicitly test their underlying items - like
# ApplicationWindow which is an AbstractApplicationWindow, making an
# instantiation test of AbstractApplicationWindow redundant.
ecm_add_qml_instantiation_tests(MODULE "org.kde.kirigami" VERSION "2.19" TESTS
    AboutPage
    ApplicationWindow
    CardsGridView
    CardsLayout
    CardsListView
    CheckableListItem
    Chip
    ContextDrawer
    Dialog
    FlexColumn
    FormLayout
    GlobalDrawer
    Heading
    Hero
    InlineMessage
    LinkButton
    ListItemDragHandle
    ListSectionHeader
    MenuDialog
    NavigationTabBar
    NavigationTabButton
    Page
    PagePoolAction
    PasswordField
    PlaceholderMessage
    PromptDialog
    RouterWindow
    ScrollablePage
    SearchField
    Separator
    ShadowedImage
    SwipeListItem
    UrlButton

    # C++ Items added by the plugin
    ShadowedRectangle
    ShadowedTexture

    # Settings
    CategorizedSettings
    SettingAction

    # Swipe Navigator
    SwipeNavigator
    PageTab
)
