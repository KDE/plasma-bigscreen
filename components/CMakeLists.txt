project(bigscreen)

set(bigscreen_SRCS
    bigscreenplugin.cpp
    )

add_library(bigscreenplugin SHARED ${bigscreen_SRCS})
target_link_libraries(bigscreenplugin Qt5::Core Qt5::Qml Qt5::Quick Qt5::Concurrent)

install(TARGETS bigscreenplugin DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/mycroft/bigscreen)

install(FILES qmldir DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/mycroft/bigscreen)

install(DIRECTORY qml/ DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/mycroft/bigscreen)


