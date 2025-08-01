# SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>
# SPDX-FileCopyrightText: 2020 Rinigus <rinigus.git@gmail.com>
# SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
# SPDX-License-Identifier: LGPL-2.0-or-later

add_executable(plasma-bigscreen-webapp
    main.cpp
    useragent.cpp
    browsermanager.cpp
    webprofile.cpp
)

ecm_add_qml_module(plasma-bigscreen-webapp-plugin URI org.kde.bigscreen.webapp.sources GENERATE_PLUGIN_SOURCE DEPENDENCIES QtQuick)

# Include qml and js files within ./qml/
file(GLOB_RECURSE _qml_sources
    "qml/*.qml"
    "qml/*.js"
)
ecm_target_qml_sources(plasma-bigscreen-webapp-plugin SOURCES ${_qml_sources})
ecm_finalize_qml_module(plasma-bigscreen-webapp-plugin)

ecm_add_qml_module(plasma-bigscreen-webapp
    GENERATE_PLUGIN_SOURCE
    URI org.kde.bigscreen.webapp
)

target_compile_definitions(plasma-bigscreen-webapp PRIVATE -DQT_NO_CAST_FROM_ASCII)
target_link_libraries(plasma-bigscreen-webapp PRIVATE
    Qt::Core
    Qt::Qml
    Qt::Quick
    Qt::Widgets
    KF6::I18n
    KF6::CoreAddons
    KF6::Notifications
)

target_link_libraries(plasma-bigscreen-webapp PRIVATE Qt::WebEngineCore Qt::WebEngineQuick)

target_include_directories(plasma-bigscreen-webapp PRIVATE ${CMAKE_BINARY_DIR})
install(TARGETS plasma-bigscreen-webapp ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})

