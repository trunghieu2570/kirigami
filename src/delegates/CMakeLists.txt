
ecm_add_qml_module(KirigamiDelegates URI "org.kde.kirigami.delegates" NO_PLUGIN)

ecm_target_qml_sources(KirigamiDelegates SOURCES
    IconTitleSubtitle.qml
    TitleSubtitle.qml
)

ecm_finalize_qml_module(KirigamiDelegates)
