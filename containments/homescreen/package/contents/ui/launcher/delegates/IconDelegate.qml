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

    signal longClick

    implicitWidth: listView ? listView.cellWidth : null
    implicitHeight: listView ? listView.height : null
    baseRadius: Kirigami.Units.gridUnit
    handleKeyReturnAsClick: false

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

    property real pressedFactor: 0
    property bool appPressed: false
    onAppPressedChanged: {
        if (appPressed){
            pressedAnim.restart();
        } else{
            pressedAnim.stop();
            pressedFactor = 0;
        }
    }
    onPressedChanged: {
        appPressed = pressed;
    }

    NumberAnimation on pressedFactor {
        id: pressedAnim
        from: 0
        to: 1
        running: false
        duration: 1000
        onFinished: {
            delegate.longClick();
            appPressed = false
        }
    }

    Keys.onPressed: (event) => {
        if (event.isAutoRepeat){
            return;
        }
        if (event.key == Qt.Key_Return){
            event.accepted = true;
            appPressed = true;
        } else{
            event.accepted = false;
        }
    }
    Keys.onReleased: (event) => {
        if (event.isAutoRepeat){
            return;
        }
        if (appPressed && event.key == Qt.Key_Return){
            event.accepted = true;

            // Don't "click" unless the user just pressed
            if (pressedFactor < 0.2){
                click();
            }
            appPressed = false;
        } else{
            event.accepted = false;
        }
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
