# SPDX-FileCopyrightText: 2026 Devin Lin <devin@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

ecm_add_qml_module(controllerhandlerplugin URI org.kde.bigscreen.controllerhandler GENERATE_PLUGIN_SOURCE)

target_sources(controllerhandlerplugin PRIVATE
    controllerhandlerstatus.cpp
    controllerhandlerstatus.h
)

target_link_libraries(controllerhandlerplugin
    PUBLIC
        Qt::Core
    PRIVATE
        Qt::Qml
        Qt::Quick
        Qt::DBus
)

ecm_finalize_qml_module(controllerhandlerplugin)
