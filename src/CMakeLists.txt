
include(${CMAKE_SOURCE_DIR}/cmake/QmlPlugin.cmake)

add_qml_plugin(kirigamiplugin org.kde.kirigami)

target_include_directories(kirigamiplugin PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/libkirigami ${CMAKE_CURRENT_BINARY_DIR}/libkirigami)

target_sources(kirigamiplugin PRIVATE
    kirigamiplugin.cpp
    columnview.cpp
    enums.cpp
    delegaterecycler.cpp
    icon.cpp
    settings.cpp
    formlayoutattached.cpp
    pagepool.cpp
    imagecolors.cpp
    scenepositionattached.cpp
    mnemonicattached.cpp
    wheelhandler.cpp
    shadowedrectangle.cpp
    shadowedtexture.cpp
    colorutils.cpp
    pagerouter.cpp
    avatar.cpp
    toolbarlayout.cpp
    toolbarlayoutdelegate.cpp
    sizegroup.cpp
    scenegraph/managedtexturenode.cpp
    scenegraph/shadowedrectanglenode.cpp
    scenegraph/shadowedrectanglematerial.cpp
    scenegraph/shadowedborderrectanglematerial.cpp
    scenegraph/paintedrectangleitem.cpp
    scenegraph/shadowedtexturenode.cpp
    scenegraph/shadowedtexturematerial.cpp
    scenegraph/shadowedbordertexturematerial.cpp
    ${CMAKE_CURRENT_BINARY_DIR}/libkirigami/loggingcategory.cpp
)

if (BUILD_SHARED_LIBS)
    ecm_create_qm_loader(kirigami_QM_LOADER libkirigami2plugin_qt)
    target_sources(kirigamiplugin PRIVATE ${kirigami_QM_LOADER})
else()
    target_sources(kirigamiplugin PRIVATE
        libkirigami/basictheme.cpp
        libkirigami/platformtheme.cpp
        libkirigami/styleselector.cpp
        libkirigami/tabletmodewatcher.cpp
        libkirigami/kirigamipluginfactory.cpp
    )
endif()

qt_add_resources(SHADERS scenegraph/shaders/shaders.qrc)
target_sources(kirigamiplugin PRIVATE ${SHADERS})

add_subdirectory(libkirigami)

if(NOT BUILD_SHARED_LIBS)
    if (UNIX AND NOT ANDROID AND NOT(APPLE) AND NOT(DISABLE_DBUS))
        qt_add_dbus_interface(_dbus_interface libkirigami/org.kde.KWin.TabletModeManager.xml tabletmodemanager_interface)
        target_sources(kirigamiplugin PRIVATE ${_dbus_interface})
    endif()
endif()

target_qml_sources(TARGET kirigamiplugin VERSION 2.5 SOURCES
    controls/AboutPage.qml
    controls/AbstractApplicationHeader.qml
    controls/AbstractApplicationItem.qml
    controls/AbstractApplicationWindow.qml
)

target_link_libraries(kirigamiplugin
    PUBLIC
        Qt5::Core
    PRIVATE
        Qt5::Qml Qt5::Quick Qt5::QuickControls2 Qt5::Concurrent
)

if(NOT BUILD_SHARED_LIBS)
    set_target_properties(kirigamiplugin PROPERTIES AUTOMOC_MOC_OPTIONS -Muri=org.kde.kirigami)
    if (UNIX AND NOT ANDROID AND NOT(APPLE) AND NOT(DISABLE_DBUS))
        target_link_libraries(kirigamiplugin PRIVATE Qt5::DBus)
    endif()
else()
    if(WIN32)
        set_target_properties(kirigamiplugin PROPERTIES PREFIX "")
    endif()

    target_link_libraries(kirigamiplugin PRIVATE KF5::Kirigami2)
endif()

install_qml_plugin(TARGET kirigamiplugin DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/kirigami)
