/*
    SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2019 Aditya Mehra <aix.m@outlook.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQml.Models
import org.kde.plasma.plasmoid
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami
import org.kde.kdeconnect as KDEConnect
import org.kde.plasma.private.nanoshell as NanoShell
import org.kde.private.biglauncher

AbstractIndicator {
    id: settingsIcon
    icon.name: "configure"

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