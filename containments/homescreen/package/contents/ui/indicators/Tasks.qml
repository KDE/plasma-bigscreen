/*
    SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2019 Aditya Mehra <aix.m@outlook.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Window
import org.kde.plasma.plasmoid
import org.kde.private.biglauncher

AbstractIndicator {
    id: tasksIcon
    icon.name: "transform-shear-up"
    text: i18n('Tasks')

    onClicked: {
        taskWindowView.showOverlay()
    }

    Connections {
        target: plasmoid.Shortcuts

        function onToggleTasksOverlay() {
            if(!taskWindowView.active) {
                taskWindowView.showOverlay()
            } else {
                taskWindowView.hideOverlay()
            }
        }
        function onToggleHomeScreen() {
            taskWindowView.minimizeAllTasks()
        }
    }
}