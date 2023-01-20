set(applicationitemapp_SRCS
    main.cpp
    )

qt_add_resources(RESOURCES resources.qrc)

add_executable(applicationitemapp ${applicationitemapp_SRCS} ${RESOURCES})
target_link_libraries(applicationitemapp Qt${QT_MAJOR_VERSION}::Core  Qt${QT_MAJOR_VERSION}::Qml Qt${QT_MAJOR_VERSION}::Quick Qt${QT_MAJOR_VERSION}::Svg)
if(${QT_MAJOR_VERSION} EQUAL 6)
    find_package(Qt${QT_MAJOR_VERSION} ${QT_MIN_VERSION} REQUIRED NO_MODULE COMPONENTS
        Widgets
    )
    target_link_libraries(applicationitemapp Qt${QT_MAJOR_VERSION}::Widgets)
endif()

install(TARGETS applicationitemapp ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})

include(${CMAKE_SOURCE_DIR}/KF6Kirigami2Macros.cmake)
