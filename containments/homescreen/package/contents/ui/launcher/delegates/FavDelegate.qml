/*
    SPDX-FileCopyrightText: 2019 Aditya Mehra <aix.m@outlook.com>
    SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.bigscreen as Bigscreen
import org.kde.kirigami as Kirigami
import org.kde.plasma.private.nanoshell as NanoShell
import org.kde.plasma.plasmoid

Bigscreen.AbstractDelegate {
    id: delegate
    readonly property var appStorageIdRole: modelData.ApplicationStorageIdRole
    implicitWidth: listView.cellWidth
    implicitHeight: listView.height
    shadowSize: Kirigami.Units.smallSpacing

    // text: modelData ? modelData.ApplicationNameRole : ""
    property bool useIconColors: plasmoid.configuration.coloredTiles

    Kirigami.Theme.inherit: !imagePalette.useColors
    Kirigami.Theme.textColor: imagePalette.textColor
    Kirigami.Theme.backgroundColor: imagePalette.backgroundColor
    Kirigami.Theme.highlightColor: Kirigami.Theme.accentColor

    Kirigami.ImageColors {
        id: imagePalette
        property bool useColors: useIconColors
        property color backgroundColor: useColors ? dominantContrast : Kirigami.Theme.backgroundColor
        property color accentColor: useColors ? highlight : Kirigami.Theme.highlightColor
        property color textColor: useColors ? (Kirigami.ColorUtils.brightnessForColor(dominantContrast) === Kirigami.ColorUtils.Light ? imagePalette.closestToBlack : imagePalette.closestToWhite) : Kirigami.Theme.textColor
    }

    contentItem: Item {
        GridLayout {
            anchors.fill: parent
            columns: 1
            rows: 2

            Kirigami.Icon {
                id: iconItem
                Layout.preferredWidth: parent.width * 0.6
                Layout.preferredHeight: textBackground.visible ? width - textBackground.height : width 
                Layout.alignment: textBackground.visible ? Qt.AlignTop | Qt.AlignHCenter : Qt.AlignVCenter | Qt.AlignHCenter
                source: modelData.ApplicationIconRole
                property var pathRegex: /^(\/[^\/]+)+$/;
                onStatusChanged:{
                    if (status === 1) {
                        if (pathRegex.test(source)) {
                            console.log("Snaps/Flatpak icon color not supported.");
                        } else {
                            imagePalette.source = iconItem.source;
                            imagePalette.update();
                        }
                    }
                }
            }

            Label {
                id: textBackground
                Layout.fillWidth: true
                Layout.preferredHeight: Kirigami.Units.gridUnit * 4
                Layout.alignment: Qt.AlignBottom | Qt.AlignHCenter
                color: Kirigami.Theme.textColor
                width: parent.width
                text: modelData ? modelData.ApplicationNameRole : ""
                visible: isCurrent
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: width * 0.1
                font.bold: true
                maximumLineCount: 2
                wrapMode: Text.WordWrap
                elide: Text.ElideRight
            }
        }
    }

    onClicked: {
        Bigscreen.NavigationSoundEffects.playClickedSound()
        NanoShell.StartupFeedback.open(
                            delegate.icon.name.length > 0 ? delegate.icon.name : model.decoration,
                            delegate.text,
                            delegate.Kirigami.ScenePosition.x + delegate.width/2,
                            delegate.Kirigami.ScenePosition.y + delegate.height/2,
                            Math.min(delegate.width, delegate.height), delegate.Kirigami.Theme.backgroundColor);
        plasmoid.applicationListModel.runApplication(modelData.ApplicationStorageIdRole)
    }
}
