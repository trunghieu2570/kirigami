
add_library(KirigamiDialogs)
ecm_add_qml_module(KirigamiDialogs URI "org.kde.kirigami.dialogs"
    VERSION 2.0
    GENERATE_PLUGIN_SOURCE
    DEPENDENCIES QtQuick org.kde.kirigami.platform
)



ecm_target_qml_sources(KirigamiDialogs SOURCES
    Dialog.qml
    MenuDialog.qml
    PromptDialog.qml
    SearchDialog.qml
)

set_target_properties(KirigamiDialogs PROPERTIES
    VERSION     ${PROJECT_VERSION}
    SOVERSION   6
    EXPORT_NAME "KirigamiDialogs"
)

target_include_directories(KirigamiDialogs PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/..)

target_link_libraries(KirigamiDialogs PRIVATE Qt6::Quick KirigamiPlatform)

include_static_dependencies(KirigamiDialogs EXPORT KirigamiTargets)

ecm_finalize_qml_module(KirigamiDialogs)

if (NOT BUILD_SHARED_LIBS)
    install(TARGETS KirigamiDialogsplugin EXPORT KirigamiTargets ${KF_INSTALL_TARGETS_DEFAULT_ARGS})
endif()

install(TARGETS KirigamiDialogs EXPORT KirigamiTargets ${KF_INSTALL_DEFAULT_ARGUMENTS})
