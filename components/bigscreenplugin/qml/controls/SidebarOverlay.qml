// SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2

import org.kde.kirigami as Kirigami
import org.kde.bigscreen as Bigscreen

QQC2.Popup {
    id: root
    modal: true

    property alias header: headerControl.contentItem
    property alias content: contentControl.contentItem

    Kirigami.Theme.inherit: false
    Kirigami.Theme.colorSet: Kirigami.Theme.View

    parent: QQC2.Overlay.overlay
    height: parent.height
    width: Math.min(Kirigami.Units.gridUnit * 40, Math.max(Kirigami.Units.gridUnit * 25, Math.round(parent.width * 0.3)))

    topPadding: 0
    bottomPadding: 0
    leftPadding: 0
    rightPadding: 0

    y: 0

    enter: Transition {
        SequentialAnimation {
            NumberAnimation {
                property: "x"
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InOutCubic
                from: root.parent.width; to: root.parent.width - root.width
            }
            // Make sure it's anchored to the right of the screen
            ScriptAction { script: root.x = Qt.binding(() => (root.parent.width - root.width)); }
        }
    }

    exit: Transition {
        NumberAnimation {
            property: "x"
            duration: Kirigami.Units.longDuration
            easing.type: Easing.InOutCubic
            to: root.parent.width; from: root.parent.width - root.width
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
            anchors.right: frame.right
            anchors.bottom: parent.bottom
            opacity: 0.1

            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: 'transparent' }
                GradientStop { position: 1.0; color: 'black' }
            }
        }
    }

    contentItem: ColumnLayout {
        spacing: 0

        QQC2.Control {
            id: headerControl
            visible: contentItem
            implicitHeight: parent.height * 0.4

            topPadding: Kirigami.Units.gridUnit
            bottomPadding: Kirigami.Units.gridUnit
            leftPadding: Kirigami.Units.gridUnit
            rightPadding: Kirigami.Units.gridUnit

            Layout.fillWidth: true

            background: Rectangle {
                color: Kirigami.Theme.alternateBackgroundColor
            }

            contentItem: null
        }
        QQC2.Control {
            id: contentControl
            Layout.fillWidth: true
            Layout.fillHeight: true

            topPadding: Kirigami.Units.gridUnit
            bottomPadding: Kirigami.Units.gridUnit
            leftPadding: Kirigami.Units.gridUnit
            rightPadding: Kirigami.Units.gridUnit
        }
    }
}