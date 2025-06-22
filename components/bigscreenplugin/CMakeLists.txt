# SPDX-FileCopyrightText: 2020 Marco Martin <mart@kde.org>
# SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

ecm_add_qml_module(bigscreenplugin URI org.kde.bigscreen GENERATE_PLUGIN_SOURCE DEPENDENCIES QtQuick)

set(bigscreenplugin_SRCS
    envreader.cpp
    bigscreenplugin_dbus.cpp
    global.cpp
)

target_sources(bigscreenplugin PRIVATE ${bigscreenplugin_SRCS})

# Singleton declarations
set_source_files_properties(
    qml/NavigationSoundEffects.qml
    qml/controls/Units.qml
    PROPERTIES
    QT_QML_SINGLETON_TYPE TRUE
)

# Include qml and js files within ./qml/
file(GLOB_RECURSE _qml_sources
    "qml/*.qml"
    "qml/*.js"
)
ecm_target_qml_sources(bigscreenplugin SOURCES ${_qml_sources})

target_link_libraries(bigscreenplugin
    PUBLIC
        Qt::Core
    PRIVATE
        Qt::Qml
        Qt::Quick
        Qt::DBus
)

ecm_finalize_qml_module(bigscreenplugin)
