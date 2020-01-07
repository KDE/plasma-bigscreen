/*
 *  Copyright 2019 Aditya Mehra <aix.m@outlook.com>
 *  Copyright 2019 Marco Martin <mart@kde.org>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  2.010-1301, USA.
 */

import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents2
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kirigami 2.11 as Kirigami
import QtGraphicalEffects 1.0
import org.kde.plasma.networkmanagement 0.2 as PlasmaNM

PlasmaComponents.ItemDelegate {
    id: delegate

    property bool activating: model.ConnectionState == PlasmaNM.Enums.Activating
    property bool deactivating: model.ConnectionState == PlasmaNM.Enums.Deactivating
    property bool predictableWirelessPassword: !model.Uuid && model.Type == PlasmaNM.Enums.Wireless &&
                                               (model.SecurityType == PlasmaNM.Enums.StaticWep || model.SecurityType == PlasmaNM.Enums.WpaPsk ||
                                                model.SecurityType == PlasmaNM.Enums.Wpa2Psk)

    checked: connectionView.currentIndex === index && connectionView.activeFocus

    implicitWidth: listView.cellWidth
    implicitHeight: listView.height + Kirigami.Units.largeSpacing

    readonly property ListView listView: ListView.view

    z: listView.currentIndex == index ? 2 : 0

    leftPadding: frame.margins.left + background.extraMargin
    topPadding: frame.margins.top + background.extraMargin
    rightPadding: frame.margins.right + background.extraMargin
    bottomPadding: frame.margins.bottom + background.extraMargin

    background: Item {
        id: background
        property real extraMargin:  Math.round(listView.currentIndex == index && delegate.activeFocus ? -units.gridUnit/2 : units.gridUnit/2)
        Behavior on extraMargin {
            NumberAnimation {
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InOutQuad
            }
        }

        PlasmaCore.FrameSvgItem {
            anchors {
                fill: frame
                leftMargin: -margins.left
                topMargin: -margins.top
                rightMargin: -margins.right
                bottomMargin: -margins.bottom
            }
            imagePath: "dialogs/background"
            prefix: "shadow"
        }
        PlasmaCore.FrameSvgItem {
            id: frame
            anchors {
                fill: parent
                margins: background.extraMargin
            }
            imagePath: "dialogs/background"
            
            width: listView.currentIndex == index && delegate.activeFocus ? parent.width : parent.width - units.gridUnit
            height: listView.currentIndex == index && delegate.activeFocus ? parent.height : parent.height - units.gridUnit
            opacity: 0.8
        }
    }

    contentItem: ColumnLayout {
        id: connectionItemLayout
        anchors {
            left: parent.left;
            top: parent.top;
            right: parent.right;
        }
            
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Math.round(units.gridUnit / 2)
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                        
            Kirigami.Icon {
                id: connectionSvgIcon
                Layout.topMargin: Kirigami.Units.largeSpacing
                Layout.preferredWidth: Kirigami.Units.iconSizes.huge
                Layout.preferredHeight: width
                Layout.alignment: Qt.AlignHCenter
                source: itemSignalIcon(model.Signal)
            }

            Kirigami.Heading {
                id: connectionNameLabel
                Layout.alignment: Qt.AlignHCenter
                level: 2
                elide: Text.ElideRight
                font.weight: model.ConnectionState == PlasmaNM.Enums.Activated ? Font.DemiBold : Font.Normal
                font.italic: model.ConnectionState == PlasmaNM.Enums.Activating ? true : false
                text: model.ItemUniqueName
                textFormat: Text.PlainText
            }

            Kirigami.Heading {
                id: connectionStatusLabel
                Layout.alignment: Qt.AlignHCenter
                level: 3
                elide: Text.ElideRight
                opacity: 0.6
                text: itemText()
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
