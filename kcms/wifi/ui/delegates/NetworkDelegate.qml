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

Bigscreen.ButtonDelegate {
    id: delegate

    required property var model
    property bool activating: model.ConnectionState == PlasmaNM.Enums.Activating
    property bool deactivating: model.ConnectionState == PlasmaNM.Enums.Deactivating
    property bool predictableWirelessPassword: !model.Uuid && model.Type == PlasmaNM.Enums.Wireless &&
                                               (model.SecurityType == PlasmaNM.Enums.StaticWep || model.SecurityType == PlasmaNM.Enums.WpaPsk ||
                                                model.SecurityType == PlasmaNM.Enums.Wpa2Psk || model.SecurityType == PlasmaNM.Enums.SAE)

    text: model.ItemUniqueName
    // itemLabelFont: Qt.font({
    //     weight: model.ConnectionState == PlasmaNM.Enums.Activated ? Font.DemiBold : Font.Normal,
    //     italic: model.ConnectionState == PlasmaNM.Enums.Activating ? true : false
    // })

    // description: itemText()
    // itemTickSource: Qt.resolvedUrl("../images/green-tick-thick.svg")
    // itemTickOpacity: model.ConnectionState == PlasmaNM.Enums.Activated ? 1 : 0

    icon.name: switch(model.Type) {
        case PlasmaNM.Enums.Wireless:
            return itemSignalIcon(model.Signal)
        case PlasmaNM.Enums.Wired:
            return "network-wired-activated"
    }

    trailing: Kirigami.Icon {
        visible: model.ConnectionState == PlasmaNM.Enums.Activated
        implicitWidth: Kirigami.Units.iconSizes.medium
        implicitHeight: Kirigami.Units.iconSizes.medium
        source: 'checkmark'
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
}
