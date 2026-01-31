// SPDX-FileCopyrightText: 2026 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import QtQuick.Templates as T

import org.kde.kirigami as Kirigami
import org.kde.bigscreen as Bigscreen

T.Popup {
    id: root

    dim: false
    modal: true

    Kirigami.Theme.inherit: false
    Kirigami.Theme.colorSet: Kirigami.Theme.View

    parent: QQC2.Overlay.overlay
    height: parent.height
    width: parent.width

    property real sidebarWidth: frame.width

    topPadding: 0
    bottomPadding: 0
    leftPadding: 0
    rightPadding: 0

    readonly property real openFactor: 1 - Math.abs(x / sidebarWidth)

    y: 0

    enter: Transition {
        SequentialAnimation {
            NumberAnimation {
                property: "x"
                duration: 400
                easing.type: Easing.OutCubic
                from: -root.sidebarWidth; to: 0
            }
            // Make sure it's anchored to the left of the screen
            ScriptAction { script: root.x = Qt.binding(() => 0); }
        }
    }

    exit: Transition {
        NumberAnimation {
            property: "x"
            duration: 400
            easing.type: Easing.OutCubic
            to: -root.sidebarWidth; from: 0
        }
    }

    background: Item {
        Rectangle {
            id: frame
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: Math.min(Kirigami.Units.gridUnit * 26, Math.max(Kirigami.Units.gridUnit * 20, Math.round(parent.width * 0.3)))
            color: Kirigami.Theme.backgroundColor
        }

        // Shadow
        Rectangle {
            width: Kirigami.Units.largeSpacing
            anchors.top: parent.top
            anchors.left: frame.right
            anchors.bottom: parent.bottom
            opacity: 0.1

            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 1.0; color: 'transparent' }
                GradientStop { position: 0.0; color: 'black' }
            }
        }
    }
}
