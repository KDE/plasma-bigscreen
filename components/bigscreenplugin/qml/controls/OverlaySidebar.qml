// SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2

import org.kde.kirigami as Kirigami
import org.kde.bigscreen as Bigscreen

OverlayWindow {
    id: root

    property alias header: headerControl.contentItem
    property alias contentItem: contentControl.contentItem

    function open() {
        root.showOverlay();
    }

    onOpenRequested: {
        sideBar.state = 'open';
    }
    onCloseRequested: {
        sideBar.state = 'closed';
    }

    content: Item {
        MouseArea {
            anchors.fill: parent
            onClicked: root.hideOverlay()
        }

        QQC2.Control {
            id: sideBar
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom

            width: Math.min(Kirigami.Units.gridUnit * 40, Math.max(Kirigami.Units.gridUnit * 25, Math.round(parent.width * 0.3)))

            Kirigami.Theme.inherit: false
            Kirigami.Theme.colorSet: Kirigami.Theme.View

            property real offset: width
            transform: Translate { x: sideBar.offset }

            state: 'closed'
            states: [
                State {
                    name: 'open'
                    PropertyChanges {
                        target: sideBar
                        offset: 0
                    }
                },
                State {
                    name: 'closed'
                    PropertyChanges {
                        target: sideBar
                        offset: width
                    }
                }
            ]

            transitions: [
                Transition {
                    NumberAnimation {
                        property: "offset"
                        duration: Kirigami.Units.longDuration
                        easing.type: Easing.InOutCubic
                    }
                }
            ]

            // avoid clicks going behind
            background: MouseArea {}

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

                    background: Rectangle {
                        color: Kirigami.Theme.backgroundColor
                    }

                    topPadding: Kirigami.Units.gridUnit
                    bottomPadding: Kirigami.Units.gridUnit
                    leftPadding: Kirigami.Units.gridUnit
                    rightPadding: Kirigami.Units.gridUnit
                }
            }
        }

        // Shadow
        Rectangle {
            width: Kirigami.Units.largeSpacing
            anchors.top: parent.top
            anchors.right: sideBar.right
            anchors.bottom: parent.bottom
            opacity: 0.1

            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: 'transparent' }
                GradientStop { position: 1.0; color: 'black' }
            }
        }
    }
}