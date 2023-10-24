set(KIRIGAMI_INSTALL_INCLUDEDIR "${KDE_INSTALL_INCLUDEDIR_KF}/Kirigami2")

add_library(KF6Kirigami2)
add_library(KF6::Kirigami2 ALIAS KF6Kirigami2)

set_target_properties(KF6Kirigami2 PROPERTIES
    VERSION     ${KIRIGAMI2_VERSION}
    SOVERSION   ${KIRIGAMI2_SOVERSION}
    EXPORT_NAME "Kirigami2"
)

target_sources(KF6Kirigami2 PRIVATE
    platformtheme.cpp
    basictheme.cpp
    kirigamipluginfactory.cpp
    tabletmodewatcher.cpp
    styleselector.cpp
    units.cpp
    virtualkeyboardwatcher.cpp
)

set(libkirigami_extra_sources "")

#use dbus on linux, bsd etc, but not android and apple stuff
if (UNIX AND NOT ANDROID AND NOT(APPLE) AND NOT(DISABLE_DBUS))
    set_source_files_properties(org.freedesktop.portal.Settings.xml PROPERTIES INCLUDE dbustypes.h)
    qt_add_dbus_interface(libkirigami_extra_sources org.freedesktop.portal.Settings.xml settings_interface)
    set(LIBKIRIGAMKI_EXTRA_LIBS Qt6::DBus)
endif()

ecm_qt_declare_logging_category(libkirigami_extra_sources
    HEADER loggingcategory.h
    IDENTIFIER KirigamiLog
    CATEGORY_NAME kf.kirigami
    DESCRIPTION "Kirigami"
    DEFAULT_SEVERITY Warning
    EXPORT KIRIGAMI
)

ecm_qt_install_logging_categories(
    EXPORT KIRIGAMI
    FILE kirigami.categories
    DESTINATION ${KDE_INSTALL_LOGGINGCATEGORIESDIR}
)

ecm_generate_export_header(KF6Kirigami2
    VERSION ${KF_VERSION}
    BASE_NAME Kirigami2
    USE_VERSION_HEADER
    DEPRECATION_VERSIONS
)

target_sources(KF6Kirigami2 PRIVATE ${libkirigami_extra_sources})

target_include_directories(KF6Kirigami2
    PRIVATE ${CMAKE_CURRENT_SOURCE_DIR} ${CMAKE_CURRENT_BINARY_DIR}
    INTERFACE "$<INSTALL_INTERFACE:${KIRIGAMI_INSTALL_INCLUDEDIR}>"
)

target_link_libraries(KF6Kirigami2
    PUBLIC
        Qt6::Core
        Qt6::Qml
        Qt6::Quick
    PRIVATE
        Qt6::QuickControls2
        ${LIBKIRIGAMKI_EXTRA_LIBS}
)

ecm_generate_headers(Kirigami2_CamelCase_HEADERS
    HEADER_NAMES
    PlatformTheme
    KirigamiPluginFactory
    TabletModeWatcher
    Units
    VirtualKeyboardWatcher

    PREFIX Kirigami
    REQUIRED_HEADERS Kirigami2_HEADERS
)

if(NOT BUILD_SHARED_LIBS)
    ecm_generate_headers(Kirigami2_HEADERS
        HEADER_NAMES KirigamiPlugin
        REQUIRED_HEADERS Kirigami2_HEADERS
        RELATIVE ..
    )
endif()

install(TARGETS KF6Kirigami2
        EXPORT KF6Kirigami2Targets
        ${KF_INSTALL_TARGETS_DEFAULT_ARGS})

if(BUILD_SHARED_LIBS)
    list(APPEND Kirigami2_HEADERS ${CMAKE_CURRENT_BINARY_DIR}/kirigami2_export.h)
endif()

install(FILES ${Kirigami2_HEADERS}
        DESTINATION ${KIRIGAMI_INSTALL_INCLUDEDIR}/kirigami # prefix matching C++ namespace
        COMPONENT Devel)
install(FILES ${Kirigami2_CamelCase_HEADERS}
        DESTINATION ${KIRIGAMI_INSTALL_INCLUDEDIR}/Kirigami # prefix matching C++ namespace
        COMPONENT Devel)

if(BUILD_QCH)
    ecm_add_qch(
        KF6Kirigami2_QCH
        NAME Kirigami2
        BASE_NAME KF6Kirigami2
        VERSION ${KF_VERSION}
        ORG_DOMAIN org.kde
        SOURCES # using only public headers, to cover only public API
            ${Kirigami2_HEADERS}
        MD_MAINPAGE "${CMAKE_SOURCE_DIR}/README.md"
        LINK_QCHS
            Qt6Core_QCH
        BLANK_MACROS
            KIRIGAMI_EXPORT
            KIRIGAMI_DEPRECATED
        TAGFILE_INSTALL_DESTINATION ${KDE_INSTALL_QTQCHDIR}
        QCH_INSTALL_DESTINATION ${KDE_INSTALL_QTQCHDIR}
        COMPONENT Devel
    )
endif()

