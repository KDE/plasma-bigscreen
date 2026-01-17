/*
    SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2019 Aditya Mehra <aix.m@outlook.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts

import org.kde.plasma.plasmoid
import org.kde.private.biglauncher

AbstractIndicator {
    id: settingsIcon
    icon.name: "configure"
    text: i18n("Settings")

    onClicked: {
        Plasmoid.openSettings();
    }

    Connections {
        target: Shortcuts

        function onToggleSettingsOverlay() {
            Plasmoid.openSettings();
        }
    }
}
