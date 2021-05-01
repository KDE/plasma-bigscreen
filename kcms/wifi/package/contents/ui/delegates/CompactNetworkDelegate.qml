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

    implicitWidth: isCurrent ? listView.cellWidth * 2 : listView.cellWidth
    implicitHeight: listView.height + Kirigami.Units.largeSpacing
    
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
            width: listView.cellWidth - delegate.leftPadding - (delegate.isCurrent ? 0 : delegate.rightPadding)
            height: isCurrent ? width : width - Kirigami.Units.largeSpacing * 4
            source: itemSignalIcon(model.Signal)
            Behavior on width {
                NumberAnimation {
                    duration: Kirigami.Units.longDuration
                    easing.type: Easing.InOutQuad
                }
            }
        }
                    
        ColumnLayout {
            width: listView.cellWidth - delegate.leftPadding -  delegate.rightPadding
            anchors.right: parent.right
            y: delegate.isCurrent ? connectionItemLayout.height / 2 - height / 2 : connectionItemLayout.height - (connectionNameLabel.height + connectionStatusLabel.height + Kirigami.Units.largeSpacing)

            Kirigami.Heading {
                id: connectionNameLabel
                Layout.fillWidth: true
                visible: text.length > 0
                level: 3
                elide: Text.ElideRight
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
                font.weight: model.ConnectionState == PlasmaNM.Enums.Activated ? Font.DemiBold : Font.Normal
                font.italic: model.ConnectionState == PlasmaNM.Enums.Activating ? true : false
                text: model.ItemUniqueName
                maximumLineCount: 2
                color: Kirigami.Theme.textColor
                textFormat: Text.PlainText
            }

            Kirigami.Heading {
                id: connectionStatusLabel
                level: 3
                elide: Text.ElideRight
                Layout.fillWidth: true
                visible: text.length > 0
                maximumLineCount: 1
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                opacity: 0.6
                text: itemText()
                color: Kirigami.Theme.textColor
                textFormat: Text.PlainText
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
        listView.currentIndex = index
        listView.positionViewAtIndex(index, ListView.Contain)
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
