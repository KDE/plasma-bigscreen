/*
 * Copyright 2020 Aditya Mehra <aix.m@outlook.com>
 * Copyright 2015 Aleix Pol Gonzalez <aleixpol@kde.org>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License or (at your option) version 3 or any later version
 * accepted by the membership of KDE e.V. (or its successor approved
 * by the membership of KDE e.V.), which shall act as a proxy
 * defined in Section 14 of version 3 of the license.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */


import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents2
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kirigami 2.11 as Kirigami
import org.kde.mycroft.bigscreen 1.0 as BigScreen
import org.kde.kdeconnect 1.0
import QtGraphicalEffects 1.0

import "delegates" as Delegates

Rectangle {
    id: deviceView
    color: Kirigami.Theme.backgroundColor
    property QtObject currentDevice
    property bool hasPairingRequests: deviceView.currentDevice.hasPairingRequests
    property bool isTrusted: deviceView.currentDevice.isTrusted
    property bool isReachable: deviceView.currentDevice.isReachable
    
    onCurrentDeviceChanged: checkCurrentStatus()
    
    onHasPairingRequestsChanged: {
        if(hasPairingRequests) {
            checkCurrentStatus()
        }
    }
    
    onIsTrustedChanged: checkCurrentStatus()
    onIsReachableChanged: checkCurrentStatus()
    
    onActiveFocusChanged: {
        if(activeFocus){
            deviceStatView.forceActiveFocus()
        }
    }
    
    function checkCurrentStatus() {
        //if (deviceView.currentDevice.hasPairingRequests) {
        //    deviceStatView.currentIndex = 1
        //} else
        // disable pairing request handler in kcm as indicator handles pairing in bigscreen
        if (deviceView.currentDevice.isReachable) {
            if (deviceView.currentDevice.isTrusted) {
                deviceIconStatus.source = deviceView.currentDevice.statusIconName
                deviceStatView.currentIndex = 2
                
            } else {
                deviceIconStatus.source = deviceView.currentDevice.iconName
                deviceStatView.currentIndex = 0
            }
            
        } else {
            deviceStatView.currentIndex = 3
        }
    }    
    
    ColumnLayout {
        id: colLayoutSettingsItem
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            margins: Kirigami.Units.largeSpacing
        }
        
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: parent.height / 3
            Layout.alignment: Qt.AlignTop
            
            RowLayout {
                id: headerAreaSettingsItem
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: backBtnSettingsItem.height
        
                PlasmaComponents2.Button {
                    id: backBtnSettingsItem
                    iconSource: "arrow-left"
                    Layout.alignment: Qt.AlignLeft
                    
                    KeyNavigation.down: deviceStatView
                    
                    PlasmaComponents2.Highlight {
                        z: -2
                        anchors.fill: parent
                        anchors.margins: -Kirigami.Units.gridUnit / 4
                        visible: backBtnSettingsItem.activeFocus ? 1 : 0
                    }
                    
                    Keys.onReturnPressed: {
                        clicked()
                    }
                    
                    onClicked: {
                        connectionView.forceActiveFocus()
                    }
                }
        
                Label {
                    id: backbtnlabelHeading
                    text: "Press the [←] Back button to return to device selection"
                    wrapMode: Text.WordWrap
                    maximumLineCount: 2
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignRight
                }
            }
            
            Kirigami.Separator {
                id: headrSept
                anchors.top: headerAreaSettingsItem.bottom
                anchors.topMargin: Kirigami.Units.largeSpacing * 3
                width: parent.width
                height: 1
            }
            
            Rectangle {
                id: dIcon
                anchors.top: headrSept.bottom
                anchors.topMargin: Kirigami.Units.largeSpacing
                anchors.horizontalCenter: parent.horizontalCenter
                width: Kirigami.Units.iconSizes.huge
                height: width
                radius: 100
                color: Kirigami.Theme.textColor
                
                PlasmaCore.IconItem {
                    id: deviceIconStatus
                    anchors.centerIn: parent
                    width: Kirigami.Units.iconSizes.large
                    height: width
                    source: currentDevice.iconName
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
                text: currentDevice.name
            }
        
            Kirigami.Separator {
                id: lblSept2
                anchors.top: label2.bottom
                anchors.topMargin: Kirigami.Units.smallSpacing
                height: 1
                width: parent.width
            }
            
            StackLayout {
                id: deviceStatView
                anchors.top: lblSept2.bottom
                anchors.topMargin: Kirigami.Units.largeSpacing
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                currentIndex: 0
                
                onActiveFocusChanged: {
                    if(activeFocus) {
                        deviceStatView.itemAt(currentIndex).forceActiveFocus();
                    }
                }
                
                Delegates.UnpairedView{
                    id: unpairedView
                }
                
                Delegates.PairRequest{
                    id: pairRequestView
                }
                
                Delegates.PairedView{
                    id: pairedView
                }
                
                Delegates.Unreachable{
                    id: unreachableView
                }
            }
        }
    }
}
