// SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Window
import QtQuick.Controls as QQC2

import org.kde.kirigami as Kirigami
import org.kde.bigscreen as Bigscreen
import org.kde.plasma.private.nanoshell as NanoShell

NanoShell.FullScreenOverlay {
    id: root
    color: 'transparent'

    property alias overlayColor: overlayBackground.color
    property alias content: control.contentItem

    property real closeDuration: 400

    signal openRequested()
    signal closeRequested()

    function showOverlay() {
        if (!root.visible) {
            root.showFullScreen();
            focusScope.forceActiveFocus();
        }
    }

    function hideOverlay() {
        if (root.visible) {
            root.close();
        }
    }

    onVisibleChanged: {
        if (visible) {
            opacityAnim.to = 1;
            opacityAnim.restart();
            openRequested();
        }
    }

    onClosing: (close) => {
        if (overlayBackground.opacity !== 0) {
            close.accepted = false;
            opacityAnim.to = 0;
            opacityAnim.restart();
            closeRequested();
        }
    }

    FocusScope {
        id: focusScope
        Keys.onEscapePressed: root.hideOverlay();
        anchors.fill: parent

        Rectangle {
            id: overlayBackground
            anchors.fill: parent

            color: Qt.rgba(0, 0, 0, 0.5)

            opacity: 0
            NumberAnimation on opacity {
                id: opacityAnim
                duration: root.closeDuration
                easing.type: Easing.OutCubic
                onFinished: {
                    if (overlayBackground.opacity === 0) {
                        root.close();
                    }
                }
            }

            QQC2.Control {
                id: control
                anchors.fill: parent

                topPadding: 0
                bottomPadding: 0
                leftPadding: 0
                rightPadding: 0
            }
        }
    }
}