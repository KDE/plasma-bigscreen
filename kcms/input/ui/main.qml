/*
 * SPDX-FileCopyrightText: 2026 Devin Lin <devin@kde.org>
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts

import org.kde.kirigami as Kirigami
import org.kde.bigscreen as Bigscreen

Bigscreen.ScrollablePage {
    id: root

    title: "Input"

    leftPadding: Kirigami.Units.smallSpacing
    topPadding: Kirigami.Units.smallSpacing
    rightPadding: Kirigami.Units.smallSpacing
    bottomPadding: Kirigami.Units.smallSpacing

    readonly property bool tvRemoteConnected: hasControllerType("cec")
    readonly property var connectedGameControllers: controllersByType("gameController")

    function hasControllerType(type) {
        for (let i = 0; i < kcm.connectedControllers.length; i++) {
            if (kcm.connectedControllers[i].type === type) {
                return true;
            }
        }
        return false;
    }

    function controllersByType(type) {
        let controllers = [];
        for (let i = 0; i < kcm.connectedControllers.length; i++) {
            if (kcm.connectedControllers[i].type === type) {
                controllers.push(kcm.connectedControllers[i]);
            }
        }
        return controllers;
    }

    function controllerByIdentifier(uniqueIdentifier) {
        for (let i = 0; i < kcm.connectedControllers.length; i++) {
            if (kcm.connectedControllers[i].uniqueIdentifier === uniqueIdentifier) {
                return kcm.connectedControllers[i];
            }
        }
        return null;
    }

    function updateGameControllerSidebar(controller) {
        if (!gameControllerSidebar.opened) {
            return;
        }

        if (!controller) {
            gameControllerSidebar.controller = null;
            gameControllerSidebar.close();
            return;
        }

        gameControllerSidebar.controller = controller;
    }

    Connections {
        target: kcm
        function onConnectedControllersChanged() {
            root.updateGameControllerSidebar(root.controllerByIdentifier(gameControllerSidebar.uniqueIdentifier));
        }
    }

    onActiveFocusChanged: {
        if (activeFocus) {
            kcm.refresh();
            inputEnabledDelegate.forceActiveFocus();
        }
    }

    Component {
        id: controllerDelegate

        Bigscreen.ButtonDelegate {
            width: ListView.view.width
            text: modelData.name
            icon.name: modelData.iconName
            enabled: kcm.serviceAvailable && kcm.enabled && modelData.enabled

            onClicked: {
                gameControllerSidebar.controller = modelData;
                gameControllerSidebar.open();
            }
        }
    }

    ColumnLayout {
        spacing: 0
        KeyNavigation.left: root.KeyNavigation.left

        Bigscreen.TextDelegate {
            visible: !kcm.serviceAvailable
            text: "Input daemon is not running"
            description: "Controller and remote settings are only available when plasma-bigscreen-inputhandler is running"
            icon.name: "dialog-warning-symbolic"
        }

        Bigscreen.SwitchDelegate {
            id: inputEnabledDelegate
            text: "System Navigation"
            description: "Navigate the system interface with connected controllers/remotes (apps can always still use them directly)"
            checked: kcm.enabled
            visible: kcm.serviceAvailable

            KeyNavigation.down: cecDelegate.visible ? cecDelegate : gameControllerDelegate

            onCheckedChanged: {
                if (kcm.enabled !== checked) {
                    kcm.enabled = checked;
                }
            }
        }

        Bigscreen.SwitchDelegate {
            id: cecDelegate
            text: "TV remote"
            description: "Navigate the system interface with the connected TV remote (CEC)"
            icon.name: "input-tvremote"
            checked: kcm.cecEnabled
            enabled: kcm.enabled
            visible: kcm.serviceAvailable && root.tvRemoteConnected

            KeyNavigation.down: gameControllerDelegate

            onCheckedChanged: {
                if (kcm.cecEnabled !== checked) {
                    kcm.cecEnabled = checked;
                }
            }
        }

        QQC2.Label {
            text: "Game Controllers"
            font.pixelSize: Bigscreen.Units.headingFontPixelSize
            Layout.fillWidth: true
            Layout.topMargin: Kirigami.Units.gridUnit
            Layout.bottomMargin: Kirigami.Units.gridUnit
            visible: kcm.serviceAvailable && root.connectedGameControllers.length > 0
        }

        Bigscreen.SwitchDelegate {
            id: gameControllerDelegate
            text: "Game controllers"
            description: "Use connected game controllers for system navigation"
            checked: kcm.gameControllerEnabled
            enabled: kcm.enabled
            visible: kcm.serviceAvailable && root.connectedGameControllers.length > 0

            KeyNavigation.down: autoSuppressDelegate

            onCheckedChanged: {
                if (kcm.gameControllerEnabled !== checked) {
                    kcm.gameControllerEnabled = checked;
                }
            }
        }

        Bigscreen.SwitchDelegate {
            id: autoSuppressDelegate
            text: "Automatic input suppression"
            description: "Stop controller navigation while another app is using a controller"
            checked: kcm.autoSuppressInput
            enabled: kcm.enabled
            visible: kcm.serviceAvailable

            KeyNavigation.down: gameControllersView

            onCheckedChanged: {
                if (kcm.autoSuppressInput !== checked) {
                    kcm.autoSuppressInput = checked;
                }
            }
        }

        Bigscreen.TextDelegate {
            id: noControllersDelegate
            visible: kcm.serviceAvailable && kcm.connectedControllers.length === 0
            text: "No controllers connected"
            description: "Connect a game controller or TV remote (over CEC)"
            icon.name: "input-gamepad-symbolic"
        }

        ListView {
            id: gameControllersView
            Layout.fillWidth: true
            implicitHeight: contentHeight
            model: root.connectedGameControllers
            currentIndex: 0
            visible: count > 0

            delegate: controllerDelegate
        }

        GameControllerSidebar {
            id: gameControllerSidebar
            inputEnabled: kcm.enabled

            onClosed: {
                controller = null;
                gameControllersView.forceActiveFocus();
            }
        }
    }
}
