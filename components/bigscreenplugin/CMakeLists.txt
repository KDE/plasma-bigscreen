# SPDX-FileCopyrightText: 2020 Marco Martin <mart@kde.org>
# SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

ecm_add_qml_module(bigscreenplugin URI org.kde.bigscreen GENERATE_PLUGIN_SOURCE DEPENDENCIES QtQuick)

set(bigscreenplugin_SRCS
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

ecm_target_qml_sources(bigscreenplugin SOURCES
    qml/controls/Button.qml
    qml/controls/ButtonDelegate.qml
    qml/controls/ComboBoxDelegate.qml
    qml/controls/DelegateBackground.qml
    qml/controls/Dialog.qml
    qml/controls/DialogButtonBox.qml
    qml/controls/ItemDelegate.qml
    qml/controls/PopupBackground.qml
    qml/controls/SidebarOverlay.qml
    qml/controls/SidebarOverlayHeader.qml
    qml/controls/SwitchDelegate.qml
    qml/controls/TextDelegate.qml
    qml/controls/TextField.qml
    qml/controls/Units.qml
    qml/AbstractDelegate.qml
    qml/FullScreenOverlay.qml
    qml/IconDelegate.qml
    qml/NavigationSoundEffects.qml
    qml/TileListView.qml
)

target_link_libraries(bigscreenplugin
    PUBLIC
        Qt::Core
    PRIVATE
        Qt::Qml
        Qt::Quick
        Qt::DBus
)

ecm_finalize_qml_module(bigscreenplugin)
