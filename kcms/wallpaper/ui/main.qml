// SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
// SPDX-FileCopyrightText: 2019 Aditya Mehra <aix.m@outlook.com>
// SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls as Controls

import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami
import org.kde.bigscreen as Bigscreen

KCM.SimpleKCM {
    id: container

    title: i18n('Wallpaper')
    background: null

    onActiveFocusChanged: {
        if (activeFocus) {
            wallpaperSelectorDelegate.forceActiveFocus();
        }
    }

    leftPadding: Kirigami.Units.smallSpacing
    topPadding: Kirigami.Units.smallSpacing
    rightPadding: Kirigami.Units.smallSpacing
    bottomPadding: Kirigami.Units.smallSpacing

    ColumnLayout {
        spacing: 0

        Bigscreen.ButtonDelegate {
            id: wallpaperSelectorDelegate
            Layout.fillWidth: true

            // Open wallpaper selector
            onClicked: {
                kcm.activateWallpaperSelector();
                Window.window.close();
            }

            text: i18n('Open wallpaper selector')
            icon.name: 'backgroundtool'
        }
    }
}
