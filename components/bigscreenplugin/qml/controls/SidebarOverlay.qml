// SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2

import org.kde.kirigami as Kirigami
import org.kde.bigscreen as Bigscreen

QQC2.Popup {
    id: root

    /*!
       \brief This property holds item to focus when the sidebar opens.
       \default content
     */
    property var openFocusItem: content

    property alias header: headerControl.contentItem
    property alias content: contentControl.contentItem

    modal: true

    Kirigami.Theme.inherit: false
    Kirigami.Theme.colorSet: Kirigami.Theme.View

    parent: QQC2.Overlay.overlay
    height: parent ? parent.height : null
    width: Math.min(Kirigami.Units.gridUnit * 30, Math.max(Kirigami.Units.gridUnit * 25, Math.round(parent ? (parent.width * 0.3) : 0)))

    topPadding: 0
    bottomPadding: 0
    leftPadding: 0
    rightPadding: 0

    y: 0

    onOpened: root.openFocusItem.forceActiveFocus();

    enter: Transition {
        SequentialAnimation {
            NumberAnimation {
                property: "x"
                duration: 400
                easing.type: Easing.InOutCubic
                from: (root.parent ? root.parent.width : 0); to: (root.parent ? root.parent.width : 0) - root.width
            }
            // Make sure it's anchored to the right of the screen
            ScriptAction { script: root.x = Qt.binding(() => ((root.parent ? root.parent.width : 0) - root.width)); }
        }
    }

    exit: Transition {
        NumberAnimation {
            property: "x"
            duration: 400
            easing.type: Easing.InOutCubic
            to: (root.parent ? root.parent.width : 0); from: (root.parent ? root.parent.width : 0) - root.width
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
