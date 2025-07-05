/*
    SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2019 Aditya Mehra <aix.m@outlook.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Window
import org.kde.plasma.plasmoid
import org.kde.plasma.private.nanoshell as NanoShell
import org.kde.private.biglauncher

AbstractIndicator {
    id: settingsIcon
    icon.name: "configure"
    text: i18n('Settings')

    onClicked: {
        configWindow.showOverlay()
    }

    Connections {
        target: plasmoid.Shortcuts
        function onToggleSettingsOverlay() {
            if(!configWindow.active) {
                configWindow.showOverlay()
            } else {
                configWindow.hideOverlay()
            }
        }
    }
}