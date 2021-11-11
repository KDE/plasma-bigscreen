/*
    SPDX-FileCopyrightText: 2018 Aditya Mehra <aix.m@outlook.com>

    SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL

*/

import QtQuick 2.14
import QtQuick.Layouts 1.14
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.networkmanagement 0.2 as PlasmaNM
import org.kde.kirigami 2.12 as Kirigami

Kirigami.AbstractListItem {
    id: connectionItem

    property bool activating: model.ConnectionState == PlasmaNM.Enums.Activating
    property bool deactivating: model.ConnectionState == PlasmaNM.Enums.Deactivating
    property bool predictableWirelessPassword: !model.Uuid && model.Type == PlasmaNM.Enums.Wireless &&
                                               (model.SecurityType == PlasmaNM.Enums.StaticWep || model.SecurityType == PlasmaNM.Enums.WpaPsk ||
                                                model.SecurityType == PlasmaNM.Enums.Wpa2Psk)

    checked: connectionView.currentIndex === index && connectionView.activeFocus
    contentItem: Item {
        implicitWidth: delegateLayout.implicitWidth;
        implicitHeight: delegateLayout.implicitHeight;

        ColumnLayout {
            id: delegateLayout
            anchors {
                left: parent.left;
                top: parent.top;
                right: parent.right;
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Math.round(units.gridUnit / 2)

                Kirigami.Icon {
                    id: connectionSvgIcon
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                    Layout.preferredHeight: PlasmaCore.Units.iconSizes.medium
                    Layout.preferredWidth: PlasmaCore.Units.iconSizes.medium
                    color: Kirigami.Theme.textColor
                    //elementId: model.ConnectionIcon
                    source: itemSignalIcon(model.Signal)
                }

                ColumnLayout {
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft

                    Kirigami.Heading {
                        id: connectionNameLabel
                        Layout.alignment: Qt.AlignLeft
                        level: 2
                        elide: Text.ElideRight
                        font.weight: model.ConnectionState == PlasmaNM.Enums.Activated ? Font.DemiBold : Font.Normal
                        font.italic: model.ConnectionState == PlasmaNM.Enums.Activating ? true : false
                        text: model.ItemUniqueName
                        textFormat: Text.PlainText
                    }

                    Kirigami.Heading {
                        id: connectionStatusLabel
                        Layout.alignment: Qt.AlignLeft
                        level: 3
                        elide: Text.ElideRight
                        opacity: 0.6
                        text: itemText()
                    }
                }
            }
        }
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

    Keys.onReturnPressed: clicked()
    onClicked: {
        if (!model.ConnectionPath) {
            networkSelectionView.devicePath = model.DevicePath
            networkSelectionView.specificPath = model.SpecificPath
            networkSelectionView.connectionName = connectionNameLabel.text
            networkSelectionView.securityType = model.SecurityType
            passwordLayer.open();
        } else if (model.ConnectionState == PlasmaNM.Enums.Deactivated) {
            handler.activateConnection(model.ConnectionPath, model.DevicePath, model.SpecificPath)
        } else {
            handler.deactivateConnection(model.ConnectionPath, model.DevicePath)
        }
    }

    onPressAndHold: {
        pathToRemove = model.ConnectionPath
        nameToRemove = model.ItemUniqueName
        networkActions.open()
    }
}
