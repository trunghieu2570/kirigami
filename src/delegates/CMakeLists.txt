
add_library(KirigamiDelegates)
ecm_add_qml_module(KirigamiDelegates URI "org.kde.kirigami.delegates" GENERATE_PLUGIN_SOURCE)

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

ecm_finalize_qml_module(KirigamiDelegates)

install(TARGETS KirigamiDelegates EXPORT KirigamiTargets ${KF_INSTALL_DEFAULT_ARGUMENTS})
