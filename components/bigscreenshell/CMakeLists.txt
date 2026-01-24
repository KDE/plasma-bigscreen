# SPDX-FileCopyrightText: 2026 Devin Lin <devin@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

ecm_add_qml_module(bigscreenshell URI org.kde.bigscreen.shell GENERATE_PLUGIN_SOURCE)
target_sources(bigscreenshell PRIVATE
    bigscreenshellsettings.cpp
)

target_link_libraries(bigscreenshell PRIVATE
    Qt::Qml
    Qt::DBus
    Qt::Gui
    Qt::Quick
    KF6::Service
    KF6::Package
    KF6::KIOGui
    KF6::JobWidgets
    KF6::Screen
)

ecm_finalize_qml_module(bigscreenshell)
