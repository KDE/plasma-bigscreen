/*
    SPDX-FileCopyrightText: 2019 Aditya Mehra <aix.m@outlook.com>
    SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import Qt5Compat.GraphicalEffects

import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami
import org.kde.bigscreen as Bigscreen
import org.kde.plasma.networkmanagement as PlasmaNM
import org.kde.coreaddons as KCoreAddons

Bigscreen.SidebarOverlay {
    id: root
    openFocusItem: networkInfoButton

    property var model: null

    // Use this field to update model contents if ListView model updates (ex. connecting to network)
    property string modelItemUniqueName

    property bool activating: model && model.ConnectionState == PlasmaNM.Enums.Activating
    property bool deactivating: model && model.ConnectionState == PlasmaNM.Enums.Deactivating
    property bool predictableWirelessPassword: model && !model.Uuid && model.Type == PlasmaNM.Enums.Wireless &&
                                               (model.SecurityType == PlasmaNM.Enums.StaticWep || model.SecurityType == PlasmaNM.Enums.WpaPsk ||
                                                model.SecurityType == PlasmaNM.Enums.Wpa2Psk || model.SecurityType == PlasmaNM.Enums.SAE)
    property real rxBytes: 0
    property real txBytes: 0
    property bool showSpeed: model && model.ConnectionState == PlasmaNM.Enums.Activated &&
                             (model.Type == PlasmaNM.Enums.Wired ||
                              model.Type == PlasmaNM.Enums.Wireless ||
                              model.Type == PlasmaNM.Enums.Gsm ||
                              model.Type == PlasmaNM.Enums.Cdma)

    // Call this function specifically when changing model so we remember (since model can change networks if underlying model changes)
    function changeModel(model) {
        modelItemUniqueName = model.ItemUniqueName;
        root.model = model;
    }

    onModelChanged: {
        if (model && model.ConnectionState == PlasmaNM.Enums.Activated) {
            connectionModel.setDeviceStatisticsRefreshRateMs(model.DevicePath, showSpeed ? 2000 : 0)
        }
    }

    function itemText() {
        if (!model) return '';
        if (model.ConnectionState == PlasmaNM.Enums.Activating) {
            if (model.Type == PlasmaNM.Enums.Vpn)
                return model.VpnState
            else
                return model.DeviceState
        } else if (model.ConnectionState == PlasmaNM.Enums.Deactivating) {
            if (model.Type == PlasmaNM.Enums.Vpn)
                return model.VpnState
            else
                return model.DeviceState
        } else if (model.ConnectionState == PlasmaNM.Enums.Deactivated) {
            var result = model.LastUsed
            if (model.SecurityType > PlasmaNM.Enums.NoneSecurity)
                result += ", " + model.SecurityTypeString
            return result
        } else if (model.ConnectionState == PlasmaNM.Enums.Activated) {
            return i18n("Connected")
        }
    }

    function itemSignalIcon(signalState) {
        if (signalState <= 20){
            return model.SecurityType > PlasmaNM.Enums.NoneSecurity ? "network-wireless-20-locked" : "network-wireless-20"
        } else if (signalState <= 40){
            return model.SecurityType > PlasmaNM.Enums.NoneSecurity ? "network-wireless-40-locked" : "network-wireless-40"
        } else if (signalState <= 60){
            return model.SecurityType > PlasmaNM.Enums.NoneSecurity ? "network-wireless-60-locked" : "network-wireless-60"
        } else if (signalState <= 80){
            return model.SecurityType > PlasmaNM.Enums.NoneSecurity ? "network-wireless-80-locked" : "network-wireless-80"
        } else if (signalState <= 100){
            return model.SecurityType > PlasmaNM.Enums.NoneSecurity ? "network-wireless-100-locked" : "network-wireless-100"
        } else {
            return "network-wireless-connected-00"
        }
    }

    onShowSpeedChanged: {
        connectionModel.setDeviceStatisticsRefreshRateMs(model.DevicePath, showSpeed ? 2000 : 0)
    }

    Timer {
        id: timer
        repeat: true
        interval: 2000
        running: showSpeed
        property real prevRxBytes
        property real prevTxBytes
        Component.onCompleted: {
            if (!model) return;
            prevRxBytes = model.RxBytes
            prevTxBytes = model.TxBytes
        }
        onTriggered: {
            if (!model) return;
            rxBytes = (model.RxBytes - prevRxBytes) * 1000 / interval
            txBytes = (model.TxBytes - prevTxBytes) * 1000 / interval
            prevRxBytes = model.RxBytes
            prevTxBytes = model.TxBytes
        }
    }

    header: Bigscreen.SidebarOverlayHeader {
        iconSource: {
            if (!model) return 'network-wired-activated';
            switch(model.Type) {
            case PlasmaNM.Enums.Wireless:
                return itemSignalIcon(model.Signal)
            case PlasmaNM.Enums.Wired:
                return "network-wired-activated"
            }
        }

        title: model ? model.ItemUniqueName : ''
    }

    content: ColumnLayout {
        id: colLayoutSettingsItem
        spacing: Kirigami.Units.smallSpacing

        Bigscreen.ButtonDelegate {
            id: networkInfoButton
            icon.name: 'info'
            text: i18n("Network information")
            description: itemText()

            onClicked: infoDialog.open()
            KeyNavigation.down: connectToggleButton
            Keys.onLeftPressed: root.close()
        }

        Bigscreen.ButtonDelegate {
            id: connectToggleButton

            text: model ? (model.ConnectionState == PlasmaNM.Enums.Activated ? i18n("Disconnect") : i18n("Connect")) : ''
            icon.name: model ? (model.ConnectionState == PlasmaNM.Enums.Activated ? 'network-disconnect' : 'network-connect') : ''

            KeyNavigation.down: forgetButton
            Keys.onLeftPressed: root.close()

            onClicked: {
                // Toggle connecting to network
                if (!model.ConnectionPath) {
                    passwordDialog.devicePath = model.DevicePath
                    passwordDialog.specificPath = model.SpecificPath
                    passwordDialog.connectionName = model.ItemUniqueName
                    passwordDialog.securityType = model.SecurityType

                    if (model.SecurityType == -1) {
                        // Connect to open network
                        handler.addAndActivateConnection(model.DevicePath, model.SpecificPath, '');
                    } else {
                        passwordDialog.open();
                    }
                } else if (model.ConnectionState == PlasmaNM.Enums.Deactivated) {
                    handler.activateConnection(model.ConnectionPath, model.DevicePath, model.SpecificPath)
                } else {
                    handler.deactivateConnection(model.ConnectionPath, model.DevicePath)
                }
            }
        }

        Bigscreen.ButtonDelegate {
            id: forgetButton
            visible: model && model.ConnectionPath
            text: i18n("Forget network")
            icon.name: 'delete'

            Keys.onLeftPressed: root.close()

            onClicked: forgetDialog.open()

            Bigscreen.Dialog {
                id: forgetDialog
                standardButtons: Bigscreen.Dialog.Ok | Bigscreen.Dialog.Cancel
                title: i18n("Are you sure you want to forget the network %1?", model ? model.ItemUniqueName : '')

                onAccepted: {
                    handler.removeConnection(model.ConnectionPath);
                    forgetDialog.close();
                    networkInfoButton.forceActiveFocus();
                }
                onRejected: {
                    forgetDialog.close()
                    forgetButton.forceActiveFocus();
                }
            }
        }

        Item { Layout.fillHeight: true }

        PasswordDialog {
            id: passwordDialog
            onClosed: connectToggleButton.forceActiveFocus()
        }

        Bigscreen.Dialog {
            id: infoDialog
            title: i18n("Network details")

            onClosed: networkInfoButton.forceActiveFocus()

            contentItem: ColumnLayout {
                spacing: Kirigami.Units.smallSpacing

                DetailsText {
                    id: detailsTxtArea
                    details: model ? model.ConnectionDetails : ''
                    connected: model && model.ConnectionState == PlasmaNM.Enums.Activated ? 1 : 0
                    connectionType: model ? model.Type : 0
                    Layout.fillWidth: true
                }

                RowLayout {
                    id: speedLabel
                    Layout.fillWidth: true
                    visible: model && (model.ConnectionState == PlasmaNM.Enums.Activated ? 1 : 0)

                    Kirigami.Heading {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignLeft
                        Layout.leftMargin: Kirigami.Units.largeSpacing
                        wrapMode: Text.WordWrap
                        level: 3
                        maximumLineCount: 1
                        elide: Text.ElideRight
                        color: Kirigami.Theme.textColor
                        text: i18n("Speed")
                    }

                    PlasmaComponents.Label {
                        Layout.alignment: Qt.AlignRight
                        Layout.maximumWidth: Kirigami.Units.gridUnit * 4
                        text: "⬇ " + KCoreAddons.Format.formatByteSize(rxBytes)
                    }

                    PlasmaComponents.Label {
                        Layout.alignment: Qt.AlignRight
                        Layout.maximumWidth: Kirigami.Units.gridUnit * 4
                        text: "⬆ " + KCoreAddons.Format.formatByteSize(txBytes)
                    }
                }
            }
        }
    }
}
