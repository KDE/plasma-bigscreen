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
    implicitHeight: listView ? listView.cellHeight : null

    topPadding: 0
    bottomPadding: 0
    leftPadding: 0
    rightPadding: 0
    topInset: 0
    bottomInset: 0
    leftInset: 0
    rightInset: 0
    borderSize: 0
    
    // background: Rectangle {
    //     z:1
    //     color: "transparent"
    //     border.width: delegate.isCurrent ? 4 : 0
    //     border.color: Kirigami.Theme.highlightColor
    // }

    // Kirigami.Theme.inherit: !imagePalette.useColors
    // Kirigami.Theme.textColor: imagePalette.textColor
    // Kirigami.Theme.backgroundColor: imagePalette.backgroundColor
    // Kirigami.Theme.highlightColor: Kirigami.Theme.accentColor

    // Kirigami.ImageColors {
    //     id: imagePalette
    //     property bool useColors: useIconColors
    //     property color backgroundColor: useColors ? dominantContrast : Kirigami.Theme.backgroundColor
    //     property color accentColor: useColors ? highlight : Kirigami.Theme.highlightColor
    //     property color textColor: useColors ? (Kirigami.ColorUtils.brightnessForColor(dominantContrast) === Kirigami.ColorUtils.Light ? imagePalette.closestToBlack : imagePalette.closestToWhite) : Kirigami.Theme.textColor
    // }

    scale: delegate.activeFocus ? 1.1: 1.0
    Behavior on scale { 
        NumberAnimation { duration: Kirigami.Units.shortDuration; easing.type: Easing.OutCubic } 
    }

    contentItem: Rectangle {
        id: content
        color: "transparent"
        // radius: delegate.baseRadius
        Image {
            id: boxArt
            anchors.fill: parent
            asynchronous: true

            fillMode: Image.PreserveAspectCrop
            source: modelData && modelData.grid_path ? modelData.grid_path : ""

            // 2. Apply a rounded mask directly to the image layer:
            // layer.enabled: true
            // layer.effect: OpacityMask {
            //     maskSource: Rectangle {
            //         width: boxArt.width
            //         height: boxArt.height
            //         // radius: delegate.baseRadius
            //     }
            // }
        }
    }
    
    Rectangle {
            id: focusHintBar
            anchors.fill:parent
            
            color:Qt.rgba(0, 0, 0, 0.7)
            // Fade in only when focused by the remote

            opacity: delegate.activeFocus ? 0.0:1.0
            Behavior on opacity {
                NumberAnimation { duration: Kirigami.Units.shortDuration }
            }
        }

}
