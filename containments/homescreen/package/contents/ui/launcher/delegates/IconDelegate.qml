/*
    SPDX-FileCopyrightText: 2022 Aditya Mehra <aix.m@outlook.com>
    SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import QtQuick.Effects
import org.kde.kirigami as Kirigami
import org.kde.bigscreen as Bigscreen

Bigscreen.AbstractDelegate {
    id: delegate

    implicitWidth: listView ? listView.cellWidth : null
    implicitHeight: listView ? listView.height : null
    baseRadius: Kirigami.Units.gridUnit

    property var iconImage
    property bool useIconColors: true

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
        id: content

        ColumnLayout {
            id: topArea
            width: parent.width
            height: parent.height * 0.75
            anchors.top: parent.top

            Kirigami.Icon {
                id: iconItem
                Layout.preferredWidth: parent.height
                Layout.preferredHeight: width
                Layout.alignment: Qt.AlignHCenter
                source: delegate.iconImage || delegate.icon.name
                property var pathRegex: /^(\/[^\/]+)+$/;

                onStatusChanged: {
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

            QQC2.Label {
                id: textLabel
                Layout.fillWidth: true

                fontSizeMode: Text.Fit
                minimumPixelSize: 12

                renderType: Text.NativeRendering
                wrapMode: Text.WordWrap
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 22
                font.weight: Font.Medium
                maximumLineCount: 1
                elide: Text.ElideRight
                text: delegate.text
            }
        }
    }
}
