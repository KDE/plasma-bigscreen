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
import QtGraphicalEffects 1.0
import org.kde.plasma.networkmanagement 0.2 as PlasmaNM
import org.kde.kcoreaddons 1.0 as KCoreAddons

Item {
    id: delegateSettingsItem
    property bool activating: model.ConnectionState == PlasmaNM.Enums.Activating
    property bool deactivating: model.ConnectionState == PlasmaNM.Enums.Deactivating
    property bool predictableWirelessPassword: !model.Uuid && model.Type == PlasmaNM.Enums.Wireless &&
                                               (model.SecurityType == PlasmaNM.Enums.StaticWep || model.SecurityType == PlasmaNM.Enums.WpaPsk ||
                                                model.SecurityType == PlasmaNM.Enums.Wpa2Psk || model.SecurityType == PlasmaNM.Enums.SAE)
    property real rxBytes: 0
    property real txBytes: 0
    readonly property ListView listView: ListView.view
    property bool showSpeed: ConnectionState == PlasmaNM.Enums.Activated &&
                             (Type == PlasmaNM.Enums.Wired ||
                              Type == PlasmaNM.Enums.Wireless ||
                              Type == PlasmaNM.Enums.Gsm ||
                              Type == PlasmaNM.Enums.Cdma)
    width: listView.width
    height: listView.height
    
    Component.onCompleted: {
        if (model.ConnectionState == PlasmaNM.Enums.Activated) {
            connectionModel.setDeviceStatisticsRefreshRateMs(DevicePath, showSpeed ? 2000 : 0)
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
    
    onShowSpeedChanged: {
        connectionModel.setDeviceStatisticsRefreshRateMs(DevicePath, showSpeed ? 2000 : 0)
    }
    
    Timer {
        id: timer
        repeat: true
        interval: 2000
        running: showSpeed
        property real prevRxBytes
        property real prevTxBytes
        Component.onCompleted: {
            prevRxBytes = RxBytes
            prevTxBytes = TxBytes
        }
        onTriggered: {
            rxBytes = (RxBytes - prevRxBytes) * 1000 / interval
            txBytes = (TxBytes - prevTxBytes) * 1000 / interval
            prevRxBytes = RxBytes
            prevTxBytes = TxBytes
        }
    }
    
    ColumnLayout {
        id: colLayoutSettingsItem
        anchors {
            fill: parent
            margins: Kirigami.Units.largeSpacing
        }

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: model.ConnectionState == PlasmaNM.Enums.Activated ? parent.height : parent.height / 3
            Layout.alignment: Qt.AlignTop

            Kirigami.Icon {
                id: dIcon
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width
                height: width / 3
                source: switch(model.Type){
                        case PlasmaNM.Enums.Wireless:
                            return itemSignalIcon(model.Signal)
                        case PlasmaNM.Enums.Wired:
                            return "network-wired-activated"
                        }
            }
            
            Kirigami.Heading {
                id: label2
                width: parent.width
                anchors.top: dIcon.bottom
                anchors.topMargin: Kirigami.Units.largeSpacing
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                level: 2
                maximumLineCount: 2
                elide: Text.ElideRight
                color: PlasmaCore.ColorScope.textColor
                text: model.ItemUniqueName
            }
            
            Kirigami.Separator {
                id: lblSept
                anchors.top: label2.bottom
                anchors.topMargin: Kirigami.Units.largeSpacing
                height: 1
                anchors.left: parent.left
                anchors.leftMargin: Kirigami.Units.largeSpacing
                anchors.right: parent.right
                anchors.rightMargin: Kirigami.Units.largeSpacing
            }
            
            Rectangle {
                id: setCntStatus
                width: parent.width
                height: Kirigami.Units.gridUnit * 2
                anchors.top: lblSept.bottom
                anchors.topMargin: Kirigami.Units.smallSpacing
                color: Kirigami.Theme.backgroundColor
                
                Item {
                    anchors.fill: parent
                    
                    RowLayout {
                        anchors.centerIn: parent
                        PlasmaCore.IconItem {
                            Layout.preferredWidth: PlasmaCore.Units.iconSizes.medium
                            Layout.preferredHeight: PlasmaCore.Units.iconSizes.medium
                            source: Qt.resolvedUrl("images/green-tick-thick.svg")
                            visible: model.ConnectionState == PlasmaNM.Enums.Activated ? 1 : 0
                        }
                        Kirigami.Heading {
                            level: 3
                            text: itemText()
                        }
                    }
                }
            }
            
            Kirigami.Separator {
                id: lblSept2
                anchors.top: setCntStatus.bottom
                anchors.topMargin: Kirigami.Units.smallSpacing
                height: 1
                anchors.left: parent.left
                anchors.leftMargin: Kirigami.Units.largeSpacing
                anchors.right: parent.right
                anchors.rightMargin: Kirigami.Units.largeSpacing
            }

            DetailsText {
                id: detailsTxtArea
                visible: true
                details: ConnectionDetails
                connected: model.ConnectionState == PlasmaNM.Enums.Activated ? 1 : 0
                connectionType: model.Type
                clip: true
                anchors {
                    left: parent.left
                    right: parent.right
                    top: lblSept2.bottom
                    topMargin: Kirigami.Units.largeSpacing
                    bottom: lblSept3.top
                    bottomMargin: Kirigami.Units.smallSpacing
                }
            }
            
            Kirigami.Separator {
                id: lblSept3
                anchors.bottom: label3.top
                anchors.bottomMargin: Kirigami.Units.smallSpacing
                visible: model.ConnectionState == PlasmaNM.Enums.Activated ? 1 : 0
                height: 1
                anchors.left: parent.left
                anchors.leftMargin: Kirigami.Units.largeSpacing
                anchors.right: parent.right
                anchors.rightMargin: Kirigami.Units.largeSpacing
            }
            
            RowLayout {
                id: label3
                width: parent.width
                anchors.bottom: parent.bottom
                anchors.bottomMargin: Kirigami.Units.smallSpacing
                visible: model.ConnectionState == PlasmaNM.Enums.Activated ? 1 : 0

                Kirigami.Heading {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignLeft
                    Layout.leftMargin: Kirigami.Units.largeSpacing
                    wrapMode: Text.WordWrap
                    level: 3
                    maximumLineCount: 1
                    elide: Text.ElideRight
                    color: PlasmaCore.ColorScope.textColor
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

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: Kirigami.Units.gridUnit
        }
    }
}
