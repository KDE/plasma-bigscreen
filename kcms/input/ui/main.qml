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

    title: i18n("Input")

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
            text: i18n("Input daemon is not running")
            description: i18n("Controller and remote settings are only available when plasma-bigscreen-inputhandler is running")
            icon.name: "dialog-warning-symbolic"
        }

        Bigscreen.SwitchDelegate {
            id: inputEnabledDelegate
            text: i18n("System Navigation")
            description: i18n("Navigate the system interface with connected controllers/remotes (apps can always still use them directly)")
            checked: kcm.enabled
            visible: kcm.serviceAvailable

            property Item upDelegate: (visible && enabled) ? inputEnabledDelegate : null
            property Item downDelegate: (visible && enabled) ? inputEnabledDelegate : cecDelegate.downDelegate
            KeyNavigation.down: cecDelegate.downDelegate

            onCheckedChanged: {
                if (kcm.enabled !== checked) {
                    kcm.enabled = checked;
                }
            }
        }

        Bigscreen.SwitchDelegate {
            id: cecDelegate
            text: i18n("TV remote")
            description: i18n("Navigate the system interface with the connected TV remote (CEC)")
            icon.name: "input-tvremote-symbolic"
            checked: kcm.cecEnabled
            enabled: kcm.enabled
            visible: kcm.serviceAvailable && root.tvRemoteConnected

            property Item upDelegate: (visible && enabled) ? cecDelegate : inputEnabledDelegate.upDelegate
            property Item downDelegate: (visible && enabled) ? cecDelegate : gameControllerDelegate.downDelegate
            KeyNavigation.up: inputEnabledDelegate.upDelegate
            KeyNavigation.down: gameControllerDelegate.downDelegate

            onCheckedChanged: {
                if (kcm.cecEnabled !== checked) {
                    kcm.cecEnabled = checked;
                }
            }
        }

        QQC2.Label {
            text: i18n("Game Controllers")
            font.pixelSize: Bigscreen.Units.headingFontPixelSize
            Layout.fillWidth: true
            Layout.topMargin: Kirigami.Units.gridUnit
            Layout.bottomMargin: Kirigami.Units.gridUnit
            visible: kcm.serviceAvailable
        }

        Bigscreen.SwitchDelegate {
            id: gameControllerDelegate
            text: i18n("Game controllers")
            description: i18n("Use connected game controllers for system navigation")
            checked: kcm.gameControllerEnabled
            enabled: kcm.enabled
            visible: kcm.serviceAvailable && root.connectedGameControllers.length > 0

            property Item upDelegate: (visible && enabled) ? gameControllerDelegate : cecDelegate.upDelegate
            property Item downDelegate: (visible && enabled) ? gameControllerDelegate : autoSuppressDelegate.downDelegate
            KeyNavigation.up: cecDelegate.upDelegate
            KeyNavigation.down: autoSuppressDelegate.downDelegate

            onCheckedChanged: {
                if (kcm.gameControllerEnabled !== checked) {
                    kcm.gameControllerEnabled = checked;
                }
            }
        }

        Bigscreen.SwitchDelegate {
            id: autoSuppressDelegate
            text: i18n("Automatic input suppression")
            description: i18n("Stop controller navigation while another app is using a controller")
            checked: kcm.autoSuppressInput
            enabled: kcm.enabled && kcm.gameControllerEnabled
            visible: kcm.serviceAvailable && root.connectedGameControllers.length > 0

            property Item upDelegate: (visible && enabled) ? autoSuppressDelegate : gameControllerDelegate.upDelegate
            property Item downDelegate: (visible && enabled) ? autoSuppressDelegate : gameControllersView.downDelegate
            KeyNavigation.up: gameControllerDelegate.upDelegate
            KeyNavigation.down: gameControllersView.downDelegate

            onCheckedChanged: {
                if (kcm.autoSuppressInput !== checked) {
                    kcm.autoSuppressInput = checked;
                }
            }
        }

        Bigscreen.TextDelegate {
            id: noControllersDelegate
            visible: kcm.serviceAvailable && root.connectedGameControllers.length === 0
            text: i18n("No controllers connected")
            description: i18n("Connect a game controller")
            icon.name: "input-gamepad-symbolic"
        }

        ListView {
            id: gameControllersView
            Layout.fillWidth: true
            implicitHeight: contentHeight
            model: root.connectedGameControllers
            currentIndex: 0
            visible: count > 0

            property Item upDelegate: (visible && enabled) ? gameControllersView : autoSuppressDelegate.upDelegate
            property Item downDelegate: (visible && enabled) ? gameControllersView : null
            KeyNavigation.up: autoSuppressDelegate.upDelegate

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
