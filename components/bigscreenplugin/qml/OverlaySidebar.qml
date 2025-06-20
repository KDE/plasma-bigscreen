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

    content: Item {

        MouseArea {
            anchors.fill: parent
            onClicked: root.hideOverlay()
        }

        MouseArea {
            id: focusWrapper
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom

            width: Math.round(root.width * 0.25)

            QQC2.Control {
                id: sideBar

                Kirigami.Theme.inherit: false
                Kirigami.Theme.colorSet: Kirigami.Theme.View

                anchors.fill: parent

                contentItem: ColumnLayout {
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
        }

        // Shadow
        Rectangle {
            width: Kirigami.Units.largeSpacing
            anchors.top: parent.top
            anchors.right: focusWrapper.right
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