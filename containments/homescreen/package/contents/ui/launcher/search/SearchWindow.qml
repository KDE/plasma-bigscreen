// SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import QtQuick.Window
import QtQuick.Controls as QQC2

import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.private.nanoshell as NanoShell

import org.kde.milou as Milou
import org.kde.kirigami 2.19 as Kirigami

NanoShell.FullScreenOverlay {
    id: root

    color: 'transparent'

    function showOverlay() {
        queryField.clear();
        root.showFullScreen();
    }

    function hideOverlay() {
        root.close();
    }

    onVisibleChanged: {
        // Fade in when window is opening
        if (visible) {
            opacityAnim.to = 1;
            opacityAnim.restart();

            queryField.forceActiveFocus();
        }
    }

    onClosing: (close) => {
        // Fade out before closing
        if (windowContents.opacity !== 0) {
            close.accepted = false;
            opacityAnim.to = 0;
            opacityAnim.restart();
        }
    }

    // Search window contents
    Rectangle {
        id: windowContents
        anchors.fill: parent

        // Background color
        color: Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 0.8)

        opacity: 0
        NumberAnimation on opacity {
            id: opacityAnim
            duration: 400
            easing.type: Easing.OutCubic
            onFinished: {
                if (windowContents.opacity === 0) {
                    root.close();
                }
            }
        }

        // Hide search window when Esc is pressed
        Keys.onEscapePressed: root.hideOverlay()

        // Forward key presses to text field, and focus
        Keys.onPressed: (event) => {
            queryField.forceActiveFocus();
            if (event.key !== Qt.Key_Backspace) {
                queryField.text += event.text;
            }
        }

        Kirigami.Theme.inherit: false
        Kirigami.Theme.colorSet: Kirigami.Theme.Window

        // Background panel
        Rectangle {
            id: backgroundPanel
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: column.height - queryField.height

            color: Kirigami.Theme.backgroundColor
        }

        // Panel shadow
        Rectangle {
            height: Kirigami.Units.largeSpacing
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: backgroundPanel.top
            opacity: 0.1

            gradient: Gradient {
                orientation: Gradient.Vertical
                GradientStop { position: 0.0; color: 'transparent' }
                GradientStop { position: 1.0; color: 'black' }
            }
        }

        // Search page
        ColumnLayout {
            id: column
            anchors.fill: parent

            property real columnContentWidth: Math.max(Kirigami.Units.gridUnit * 30, width * 0.8)

            // Search field
            SearchTextField {
                id: queryField
                Layout.fillWidth: true
                Layout.maximumWidth: column.columnContentWidth
                Layout.alignment: Qt.AlignHCenter

                KeyNavigation.down: listView.count > 0 ? listView : null
            }

            // Search results
            QQC2.ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: listView.contentHeight > availableHeight
                Layout.maximumWidth: column.columnContentWidth
                Layout.alignment: Qt.AlignHCenter

                SearchListView {
                    id: listView
                    anchors.fill: parent
                    queryTextField: queryField
                    onHideOverlayRequested: root.hideOverlay()
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
            }
        }
    }
}
