/*
 * SPDX-FileCopyrightText: 2025 Seshan Ravikumar <seshan@sineware.ca>
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick
import QtQuick.Layouts
import QtQuick.Window
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami
import org.kde.bigscreen as Bigscreen
import org.kde.private.biglauncher
import org.kde.plasma.private.nanoshell as NanoShell
import org.kde.plasma.core as PlasmaCore

NanoShell.FullScreenOverlay {
    id: root

    property string title: ""
    property Item initialFocusItem: contentContainer
    property alias closeButton: closeButton
    default property alias contentItem: contentContainer.data

    width: Screen.desktopAvailableWidth
    height: Screen.desktopAvailableHeight
    visible: root.visible
    color: "transparent"

    function showOverlay() {
        if (!visible) {
            visible = true;
            if (initialFocusItem) {
                initialFocusItem.forceActiveFocus();
            }
        }
    }

    function hideOverlay() {
        if (visible) {
            visible = false;
        }
    }

    Rectangle {
        id: windowBackgroundDimmer
        anchors.fill: parent
        color: Qt.rgba(0,0,0,0.5)

        MouseArea {
            anchors.fill: parent
            onClicked: hideOverlay()
        }
    }

    Controls.Control {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: closeButton.top
        anchors.topMargin: Kirigami.Units.largeSpacing * 8
        anchors.bottomMargin: Kirigami.Units.largeSpacing * 2
        anchors.leftMargin: Kirigami.Units.largeSpacing * 8
        anchors.rightMargin: Kirigami.Units.largeSpacing * 8

        scale: root.visible ? 1.0 : 0.9
        Behavior on scale {
            NumberAnimation  {
                duration: Kirigami.Units.shortDuration
                easing.type: Easing.InOutQuad
            }
        }

        Kirigami.Theme.colorSet: Kirigami.Theme.View
        Kirigami.Theme.inherit: false

        background: Kirigami.ShadowedRectangle {
            color: Kirigami.Theme.backgroundColor
            radius: 6
            shadow {
                size: Kirigami.Units.largeSpacing * 1
            }
        }

        contentItem: Item {
            Rectangle {
                Kirigami.Theme.colorSet: Kirigami.Theme.Header
                Kirigami.Theme.inherit: false
                color: Kirigami.Theme.alternateBackgroundColor
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: Kirigami.Units.largeSpacing
                height: Kirigami.Units.gridUnit * 3
                radius: 6

                id: header

                Text {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: Kirigami.Units.largeSpacing * 3
                    text: root.title
                    font.pixelSize: 24
                    color: Kirigami.Theme.textColor
                }
            }

            Rectangle {
                anchors.top: header.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: Kirigami.Units.largeSpacing
                radius: 6

                color: Kirigami.Theme.alternateBackgroundColor

                Item {
                    id: contentContainer
                    anchors.fill: parent
                    anchors.margins: Kirigami.Units.largeSpacing
                }
            }
        }
    }
    Controls.Button {
        id: closeButton
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.bottomMargin: Kirigami.Units.largeSpacing * 8
        anchors.leftMargin: Kirigami.Units.largeSpacing * 8
        anchors.rightMargin: Kirigami.Units.largeSpacing * 8
        height: Kirigami.Units.gridUnit * 4
        width: Kirigami.Units.gridUnit * 8

        opacity: root.visible ? 1.0 : 0.5
        Behavior on opacity {
            NumberAnimation  {
                duration: Kirigami.Units.shortDuration
                easing.type: Easing.InOutQuad
            }
        }

        background: Kirigami.ShadowedRectangle {
            color: closeButton.activeFocus ? Kirigami.Theme.highlightColor : Kirigami.Theme.backgroundColor
            radius: 6
            shadow {
                size: Kirigami.Units.largeSpacing
            }
        }

        contentItem: Item {
            RowLayout {
                anchors.centerIn: parent
                Kirigami.Icon {
                    Layout.fillHeight: true
                    Layout.preferredWidth: height
                    source: "window-close"
                }
                Controls.Label {
                    fontSizeMode: Text.Fit
                    minimumPixelSize: 8
                    font.pixelSize: 18
                    text: i18n("Close")
                }
            }
        }

        onClicked: hideOverlay()
        Keys.onReturnPressed: hideOverlay()
    }
}