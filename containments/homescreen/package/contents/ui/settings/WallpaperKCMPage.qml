// SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
// SPDX-FileCopyrightText: 2019 Aditya Mehra <aix.m@outlook.com>
// SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls

import org.kde.kirigami as Kirigami
import org.kde.bigscreen as Bigscreen
import org.kde.plasma.plasmoid

// The wallpaper selection can only be done from the plasmashell process, so we need
// this custom "KCM".
Kirigami.Page {
    id: container

    onActiveFocusChanged: {
        if (activeFocus) {
            wallpaperSelectorDelegate.forceActiveFocus();
        }
    }

    Kirigami.Theme.colorSet: Kirigami.Theme.Window
    Kirigami.Theme.inherit: false

    topPadding: 0
    leftPadding: Kirigami.Units.gridUnit + Kirigami.Units.largeSpacing
    rightPadding: leftPadding
    bottomPadding: 0

    header: Item {
        id: headerAreaTop
        height: root.headerHeight
        width: parent.width

        Kirigami.Heading {
            id: settingsTitle
            text: i18n('Wallpaper')
            anchors.fill: parent

            padding: container.leftPadding
            verticalAlignment: Text.AlignBottom
            horizontalAlignment: Text.AlignLeft

            font.weight: Font.Light

            color: Kirigami.Theme.textColor
            fontSizeMode: Text.Fit
            minimumPixelSize: 16
            font.pixelSize: 32
        }
    }

    ColumnLayout {
        anchors.fill: parent

        Bigscreen.ButtonDelegate {
            id: wallpaperSelectorDelegate
            Layout.fillWidth: true

            // Open wallpaper selector
            onClicked: {
                root.hideOverlay();
                Plasmoid.internalAction("configure").trigger();
            }

            text: i18n('Open wallpaper selector')
            icon.name: 'backgroundtool'
        }

        Item { Layout.fillHeight: true }
    }
}
