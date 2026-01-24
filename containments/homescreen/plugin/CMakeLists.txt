# SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
# SPDX-FileCopyrightText: 2019 Aditya Mehra <aix.m@outlook.com>
# SPDX-License-Identifier: GPL-2.0-or-later

kde_enable_exceptions()

add_definitions(-DTRANSLATION_DOMAIN=\"biglauncherhomescreen\")

set(homescreen_SRCS
    biglauncherhomescreen.cpp biglauncherhomescreen.h
    biglauncher_dbus.cpp biglauncher_dbus.h
    applicationlistmodel.cpp applicationlistmodel.h
    favslistmodel.cpp favslistmodel.h
    shortcuts.cpp shortcuts.h
)

# DBus Interface
qt_generate_dbus_interface(
    ${CMAKE_CURRENT_SOURCE_DIR}/biglauncher_dbus.h
    org.kde.biglauncher.xml
    OPTIONS -s -m -P
)
qt_add_dbus_adaptor(homescreen_SRCS ${CMAKE_CURRENT_BINARY_DIR}/org.kde.biglauncher.xml
                    ${CMAKE_CURRENT_SOURCE_DIR}/biglauncher_dbus.h BigLauncherDbusAdapterInterface)
qt_add_dbus_interface(homescreen_SRCS ${CMAKE_CURRENT_BINARY_DIR}/org.kde.biglauncher.xml biglauncherinterface)

install(FILES ${CMAKE_CURRENT_BINARY_DIR}/org.kde.biglauncher.xml DESTINATION ${KDE_INSTALL_DBUSINTERFACEDIR})
# ---

kcoreaddons_add_plugin(org.kde.bigscreen.homescreen INSTALL_NAMESPACE "plasma/applets")
target_sources(org.kde.bigscreen.homescreen PRIVATE ${homescreen_SRCS})

target_link_libraries(org.kde.bigscreen.homescreen
    Qt::Gui
    Qt::Core
    Qt::Qml
    Qt::DBus
    Qt::Network
    Qt::Quick
    Plasma::Plasma
    KF6::I18n
    KF6::Notifications
    KF6::Service
    KF6::KIOWidgets
    KF6::KCMUtilsQuick
    KF6::GlobalAccel
    Plasma::Activities
    PW::KWorkspace
    Plasma::ActivitiesStats
)
