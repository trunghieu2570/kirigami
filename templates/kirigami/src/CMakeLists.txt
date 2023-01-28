# SPDX-License-Identifier: BSD-3-Clause
# SPDX-FileCopyrightText: %{CURRENT_YEAR} %{AUTHOR} <%{EMAIL}>

add_executable(%{APPNAMELC}
    main.cpp
    about.cpp
    app.cpp
    resources.qrc)

target_link_libraries(%{APPNAMELC} PRIVATE
    Qt5::Core
    Qt5::Gui
    Qt5::Qml
    Qt5::Quick
    Qt5::QuickControls2
    Qt5::Svg
    KF6::I18n
    KF6::CoreAddons
    KF6::ConfigCore
    KF6::ConfigGui)

if (ANDROID)
    kirigami_package_breeze_icons(ICONS
        list-add
        help-about
        application-exit
        applications-graphics
    )
else()
    target_link_libraries(%{APPNAMELC} PRIVATE Qt::Widgets)
endif()

kconfig_add_kcfg_files(%{APPNAMELC} GENERATE_MOC %{APPNAMELC}config.kcfgc)
install(TARGETS %{APPNAMELC} ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
