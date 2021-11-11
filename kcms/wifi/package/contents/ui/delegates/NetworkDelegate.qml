/*
    SPDX-FileCopyrightText: 2019 Aditya Mehra <aix.m@outlook.com>
    SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.14
import QtQuick.Layouts 1.14
import QtQuick.Controls 2.14
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents2
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kirigami 2.12 as Kirigami
import org.kde.mycroft.bigscreen 1.0 as BigScreen
import QtGraphicalEffects 1.14
import org.kde.plasma.networkmanagement 0.2 as PlasmaNM

BigScreen.AbstractDelegate {
    id: delegate

    property bool activating: model.ConnectionState == PlasmaNM.Enums.Activating
    property bool deactivating: model.ConnectionState == PlasmaNM.Enums.Deactivating
    property bool predictableWirelessPassword: !model.Uuid && model.Type == PlasmaNM.Enums.Wireless &&
                                               (model.SecurityType == PlasmaNM.Enums.StaticWep || model.SecurityType == PlasmaNM.Enums.WpaPsk ||
                                                model.SecurityType == PlasmaNM.Enums.Wpa2Psk || model.SecurityType == PlasmaNM.Enums.SAE)
    property alias connectionStatusLabelText: connectionStatusLabel.text

    checked: connectionView.currentIndex === index && connectionView.activeFocus

    implicitWidth: listView.cellWidth * 2
    implicitHeight: listView.height

    Behavior on implicitWidth {
        NumberAnimation {
            duration: Kirigami.Units.longDuration
            easing.type: Easing.InOutQuad
        }
    }

    contentItem: Item {
        id: connectionItemLayout

        PlasmaCore.IconItem {
            id: connectionSvgIcon
            width: PlasmaCore.Units.iconSizes.huge
            height: width
            y: connectionItemLayout.height/2 - connectionSvgIcon.height/2
            source: switch(model.Type){
                    case PlasmaNM.Enums.Wireless:
                        return itemSignalIcon(model.Signal)
                    case PlasmaNM.Enums.Wired:
                        return "network-wired-activated"
                    }
        }

        ColumnLayout {
            id: textLayout

            anchors {
                left: connectionSvgIcon.right
                right: connectionItemLayout.right
                top: connectionSvgIcon.top
                bottom: connectionSvgIcon.bottom
                leftMargin: Kirigami.Units.smallSpacing
            }

            PlasmaComponents.Label {
                id: connectionNameLabel
                Layout.fillWidth: true
                visible: text.length > 0
                elide: Text.ElideRight
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                maximumLineCount: 2
                color: Kirigami.Theme.textColor
                textFormat: Text.PlainText
                font.weight: model.ConnectionState == PlasmaNM.Enums.Activated ? Font.DemiBold : Font.Normal
                font.italic: model.ConnectionState == PlasmaNM.Enums.Activating ? true : false
                text: model.ItemUniqueName
            }

            PlasmaComponents.Label {
                id: connectionStatusLabel
                Layout.fillWidth: true
                visible: text.length > 0
                elide: Text.ElideRight
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                maximumLineCount: 3
                color: Kirigami.Theme.textColor
                textFormat: Text.PlainText
                opacity: 0.6
                text: itemText()
            }
        }

        Kirigami.Icon {
            id: dIcon
            anchors.bottom: parent.bottom
            anchors.bottomMargin: -Kirigami.Units.largeSpacing
            anchors.right: parent.right
            anchors.rightMargin: -Kirigami.Units.largeSpacing
            width: PlasmaCore.Units.iconSizes.smallMedium
            height: width
            source: Qt.resolvedUrl("../images/green-tick-thick.svg")
            visible: model.ConnectionState == PlasmaNM.Enums.Activated ? 1 : 0
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
        listView.currentIndex = 0
        listView.positionViewAtBeginning()
        if (!model.ConnectionPath) {
            networkSelectionView.devicePath = model.DevicePath
            networkSelectionView.specificPath = model.SpecificPath
            networkSelectionView.connectionName = connectionNameLabel.text
            networkSelectionView.securityType = model.SecurityType
            if(model.SecurityType == -1 ){
                console.log("Open Network")
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
