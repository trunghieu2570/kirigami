
add_library(KirigamiDelegates)
ecm_add_qml_module(KirigamiDelegates URI "org.kde.kirigami.delegates"
    GENERATE_PLUGIN_SOURCE
    DEPENDENCIES QtQuick org.kde.kirigami.platform org.kde.kirigami.primitives
)

ecm_target_qml_sources(KirigamiDelegates SOURCES
    IconTitleSubtitle.qml
    TitleSubtitle.qml

    SubtitleDelegate.qml
    CheckSubtitleDelegate.qml
    RadioSubtitleDelegate.qml
    SwitchSubtitleDelegate.qml
)

set_target_properties(KirigamiDelegates PROPERTIES
    VERSION     ${PROJECT_VERSION}
    SOVERSION   6
    EXPORT_NAME "KirigamiDelegates"
)

include_static_dependencies(KirigamiDelegates EXPORT KirigamiTargets)

ecm_finalize_qml_module(KirigamiDelegates)

if (NOT BUILD_SHARED_LIBS)
    install(TARGETS KirigamiDelegatesplugin EXPORT KirigamiTargets ${KF_INSTALL_TARGETS_DEFAULT_ARGS})
endif()

install(TARGETS KirigamiDelegates EXPORT KirigamiTargets ${KF_INSTALL_TARGETS_DEFAULT_ARGS})
