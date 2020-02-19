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
import org.kde.mycroft.bigscreen 1.0 as BigScreen
import QtGraphicalEffects 1.0
import org.kde.plasma.networkmanagement 0.2 as PlasmaNM

PlasmaComponents.ItemDelegate {
    id: delegate

    property bool activating: model.ConnectionState == PlasmaNM.Enums.Activating
    property bool deactivating: model.ConnectionState == PlasmaNM.Enums.Deactivating
    property bool predictableWirelessPassword: !model.Uuid && model.Type == PlasmaNM.Enums.Wireless &&
                                               (model.SecurityType == PlasmaNM.Enums.StaticWep || model.SecurityType == PlasmaNM.Enums.WpaPsk ||
                                                model.SecurityType == PlasmaNM.Enums.Wpa2Psk)
    property alias connectionStatusLabelText: connectionStatusLabel.text

    checked: connectionView.currentIndex === index && connectionView.activeFocus

    implicitWidth: isCurrent ? listView.cellWidth * 2 : listView.cellWidth
    implicitHeight: listView.height + Kirigami.Units.largeSpacing

    readonly property ListView listView: ListView.view
    readonly property bool isCurrent: listView.currentIndex == index && activeFocus

    z: isCurrent ? 2 : 0

    leftPadding: Kirigami.Units.largeSpacing * 3
    topPadding: Kirigami.Units.largeSpacing * 3
    rightPadding: Kirigami.Units.largeSpacing * 3
    bottomPadding: Kirigami.Units.largeSpacing * 3
    
    Behavior on implicitWidth {
        NumberAnimation {
            duration: Kirigami.Units.longDuration
            easing.type: Easing.InOutQuad
        }
    }

    
     BigScreen.ImagePalette {
        id: imagePalette
        sourceItem: connectionSvgIcon
        property bool useColors: BigScreen.Hack.coloredTiles
        property color backgroundColor: useColors ? suggestedContrast : PlasmaCore.ColorScope.backgroundColor
        property color accentColor: useColors ? mostSaturated : PlasmaCore.ColorScope.highlightColor
        property color textColor: useColors
            ? (0.2126 * suggestedContrast.r + 0.7152 * suggestedContrast.g + 0.0722 * suggestedContrast.b > 0.6 ? Qt.rgba(0.2,0.2,0.2,1) : Qt.rgba(0.9,0.9,0.9,1))
            : PlasmaCore.ColorScope.textColor

        readonly property bool inView: listView.width - delegate.x - connectionSvgIcon.x < listView.contentX
        onInViewChanged: {
            if (inView) {
                imagePalette.update();
            }
        }
    }
    
    background: Item {
        id: background

        PlasmaCore.FrameSvgItem {
            anchors {
                fill: frame
                leftMargin: -margins.left
                topMargin: -margins.top
                rightMargin: -margins.right
                bottomMargin: -margins.bottom
            }
            imagePath: Qt.resolvedUrl("./background.svg")
            prefix: "shadow"
        }
        Rectangle {
            id: frame
            anchors {
                fill: parent
                margins: Kirigami.Units.largeSpacing
            }
            radius: Kirigami.Units.gridUnit / 5
            color: delegate.isCurrent ? imagePalette.accentColor : imagePalette.backgroundColor
            Behavior on color {
                ColorAnimation {
                    duration: Kirigami.Units.longDuration
                    easing.type: Easing.InOutQuad
                }
            }
            Rectangle {
                anchors {
                    fill: parent
                    margins: Kirigami.Units.smallSpacing
                }
                radius: Kirigami.Units.gridUnit / 5
                color: imagePalette.backgroundColor
            }
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
                level: 2
                elide: Text.ElideRight
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
                font.weight: model.ConnectionState == PlasmaNM.Enums.Activated ? Font.DemiBold : Font.Normal
                font.italic: model.ConnectionState == PlasmaNM.Enums.Activating ? true : false
                text: model.ItemUniqueName
                maximumLineCount: 2
                color: imagePalette.textColor
                textFormat: Text.PlainText
            }

            Kirigami.Heading {
                id: connectionStatusLabel
                level: 3
                elide: Text.ElideRight
                Layout.fillWidth: true
                visible: text.length > 0
                maximumLineCount: 2
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                opacity: 0.6
                text: itemText()
                color: imagePalette.textColor
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
