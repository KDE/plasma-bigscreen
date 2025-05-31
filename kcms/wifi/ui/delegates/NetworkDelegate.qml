/*
    SPDX-FileCopyrightText: 2019 Aditya Mehra <aix.m@outlook.com>
    SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Controls
import org.kde.kirigami as Kirigami
import org.kde.bigscreen as Bigscreen
import org.kde.plasma.networkmanagement as PlasmaNM

Bigscreen.KCMAbstractDelegate {
    id: delegate

    property bool activating: model.ConnectionState == PlasmaNM.Enums.Activating
    property bool deactivating: model.ConnectionState == PlasmaNM.Enums.Deactivating
    property bool predictableWirelessPassword: !model.Uuid && model.Type == PlasmaNM.Enums.Wireless &&
                                               (model.SecurityType == PlasmaNM.Enums.StaticWep || model.SecurityType == PlasmaNM.Enums.WpaPsk ||
                                                model.SecurityType == PlasmaNM.Enums.Wpa2Psk || model.SecurityType == PlasmaNM.Enums.SAE)

    checked: connectionView.currentIndex === index && connectionView.activeFocus

    itemLabel: model.ItemUniqueName
    itemLabelFont: Qt.font({
        weight: model.ConnectionState == PlasmaNM.Enums.Activated ? Font.DemiBold : Font.Normal,
        italic: model.ConnectionState == PlasmaNM.Enums.Activating ? true : false
    })

    itemSubLabel: itemText()
    itemTickSource: Qt.resolvedUrl("../images/green-tick-thick.svg")
    itemTickOpacity: model.ConnectionState == PlasmaNM.Enums.Activated ? 1 : 0

    itemIcon: switch(model.Type) {
        case PlasmaNM.Enums.Wireless:
            return itemSignalIcon(model.Signal)
        case PlasmaNM.Enums.Wired:
            return "network-wired-activated"
    }

    function itemText() {
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
        if (signalState <= 25){
            return "network-wireless-connected-25"
        } else if (signalState <= 50){
            return "network-wireless-connected-50"
        } else if (signalState <= 75){
            return "network-wireless-connected-75"
        } else if (signalState <= 100){
            return "network-wireless-connected-100"
        } else {
            return "network-wireless-connected-00"
        }
    }

    onClicked: {
        listView.currentIndex = 0
        listView.positionViewAtBeginning()
        if (!model.ConnectionPath) {
            networkSelectionView.devicePath = model.DevicePath
            networkSelectionView.specificPath = model.SpecificPath
            networkSelectionView.connectionName = itemLabel
            networkSelectionView.securityType = model.SecurityType
            if(model.SecurityType == -1 ){
                networkSelectionView.connectToOpenNetwork()
            } else {
                passwordLayer.open();
                passField.forceActiveFocus();
            }
        } else if (model.ConnectionState == PlasmaNM.Enums.Deactivated) {
            handler.activateConnection(model.ConnectionPath, model.DevicePath, model.SpecificPath)
        } else {
            handler.deactivateConnection(model.ConnectionPath, model.DevicePath)
        }
    }

    Keys.onMenuPressed: {
        pathToRemove = model.ConnectionPath
        nameToRemove = model.ItemUniqueName
        networkActions.open()
    }

    onPressAndHold: {
        pathToRemove = model.ConnectionPath
        nameToRemove = model.ItemUniqueName
        networkActions.open()
    }
}
