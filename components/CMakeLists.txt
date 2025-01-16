project(bigscreen)

set(bigscreen_SRCS
    envreader.cpp envreader.h
    bigscreenplugin.cpp bigscreenplugin.h
    bigscreenplugin_dbus.cpp bigscreenplugin_dbus.h
    global.cpp
    )

add_library(bigscreenplugin SHARED ${bigscreen_SRCS})
target_link_libraries(bigscreenplugin Qt::Core Qt::Qml Qt::Quick Qt::DBus)

install(TARGETS bigscreenplugin DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/bigscreen)

install(FILES qmldir DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/bigscreen)

install(DIRECTORY qml/ DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/bigscreen)


