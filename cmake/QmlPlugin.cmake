
macro(_verify_qml_plugin NAME)
    if (NOT TARGET ${NAME})
        message(FATAL_ERROR "Target ${NAME} does not exist")
    endif()
    get_target_property(_qml_uri ${NAME} "_qml_uri")
    if ("${_qml_uri}" STREQUAL "")
        message(FATAL_ERROR "Target ${NAME} is not a QML plugin target")
    endif()
endmacro()

function(_generate_qmldir TARGET)
    get_target_property(_qml_uri ${TARGET} "_qml_uri")
    get_target_property(_qml_files ${TARGET} "_qml_files")

    set(_qmldir_template "module ${_qml_uri}\nplugin ${TARGET}\n")

    foreach(_file ${_qml_files})
        get_filename_component(_filename ${_file} NAME)
        get_filename_component(_classname ${_file} NAME_WE)
        get_property(_version SOURCE ${_file} PROPERTY _qml_version)
        string(APPEND _qmldir_template "\n${_classname} ${_version} ${_filename}")
    endforeach()

    string(APPEND _qmldir_template "\n")

    file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/${TARGET}_qmldir" "${_qmldir_template}")
    set_target_properties(${TARGET} PROPERTIES _qmldir_file "${CMAKE_CURRENT_BINARY_DIR}/${TARGET}_qmldir")
endfunction()

function(_generate_qrc TARGET)
    get_target_property(_qml_uri ${TARGET} "_qml_uri")
    get_target_property(_qml_files ${TARGET} "_qml_files")
    get_target_property(_qmldir_file ${TARGET} "_qmldir_file")

    string(REPLACE "." "/" _qml_prefix ${_qml_uri})

    set(_qrc_template "<RCC>\n<qresource prefix=\"${_qml_prefix}\">\n<file alias=\"qmldir\">${_qmldir_file}</file>")

    foreach(_file ${_qml_files})
        get_filename_component(_filename ${_file} NAME)
        string(APPEND _qrc_template "\n<file alias=\"${_filename}\">${CMAKE_CURRENT_SOURCE_DIR}/${_file}</file>")
    endforeach()

    string(APPEND _qrc_template "\n</qresource>\n</RCC>\n")

    file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/${TARGET}.qrc" "${_qrc_template}")
    qt5_add_resources(_qrc_output "${CMAKE_CURRENT_BINARY_DIR}/${TARGET}.qrc")

    target_sources(${TARGET} PRIVATE ${_qrc_output})
endfunction()

function(add_qml_plugin TARGET URI)
    add_library(${TARGET})

    if ("${URI}" STREQUAL "")
        message(FATAL_ERROR "A QML plugin requires a valid URI")
    endif()

    set_target_properties(${TARGET} PROPERTIES _qml_uri "${URI}")
endfunction()

function(target_qml_sources)
    cmake_parse_arguments(PARSE_ARGV 0 _QML "" "TARGET;VERSION" "SOURCES")

    _verify_qml_plugin(${_QML_TARGET})

    foreach(_file ${_QML_SOURCES})
        set_property(SOURCE ${_file} PROPERTY _qml_version "${_QML_VERSION}")
    endforeach()

    set_property(TARGET ${_QML_TARGET} APPEND PROPERTY _qml_files ${_QML_SOURCES})
endfunction()

function(install_qml_plugin)
    cmake_parse_arguments(PARSE_ARGV 0 _QML "" "TARGET;DESTINATION" "")

    _verify_qml_plugin(${_QML_TARGET})

    _generate_qmldir(${_QML_TARGET})

    if (NOT BUILD_SHARED_LIBS)
        _generate_qrc(${_QML_TARGET})
    else()
        get_target_property(_qml_files ${_QML_TARGET} "_qml_files")
        install(FILES ${_qml_files} DESTINATION ${_QML_DESTINATION})

        get_target_property(_qmldir_file ${_QML_TARGET} "_qmldir_file")
        install(FILES ${_qmldir_file} DESTINATION ${_QML_DESTINATION} RENAME "qmldir")
    endif()

    install(TARGETS ${_QML_TARGET} DESTINATION ${_QML_DESTINATION})
endfunction()
