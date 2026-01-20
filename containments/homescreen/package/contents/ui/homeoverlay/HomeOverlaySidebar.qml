// SPDX-FileCopyrightText: 2026 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2

import org.kde.kirigami as Kirigami
import org.kde.bigscreen as Bigscreen

QQC2.Popup {
    id: root

    modal: true

    Kirigami.Theme.inherit: false
    Kirigami.Theme.colorSet: Kirigami.Theme.View

    parent: QQC2.Overlay.overlay
    height: parent.height
    width: Math.min(Kirigami.Units.gridUnit * 26, Math.max(Kirigami.Units.gridUnit * 20, Math.round(parent.width * 0.3)))

    topPadding: 0
    bottomPadding: 0
    leftPadding: 0
    rightPadding: 0

    y: 0

    enter: Transition {
        SequentialAnimation {
            NumberAnimation {
                property: "x"
                duration: 400
                easing.type: Easing.InOutCubic
                from: -root.width; to: 0
            }
            // Make sure it's anchored to the left of the screen
            ScriptAction { script: root.x = Qt.binding(() => 0); }
        }
    }

    exit: Transition {
        NumberAnimation {
            property: "x"
            duration: 400
            easing.type: Easing.InOutCubic
            to: -root.width; from: 0
        }
    }

    background: Item {
        Rectangle {
            id: frame
            anchors.fill: parent
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
