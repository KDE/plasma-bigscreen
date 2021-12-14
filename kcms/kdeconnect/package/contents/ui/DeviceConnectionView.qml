/*
    SPDX-FileCopyrightText: 2020 Aditya Mehra <aix.m@outlook.com>
    SPDX-FileCopyrightText: 2015 Aleix Pol Gonzalez <aleixpol@kde.org>

    SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
*/

import QtQuick 2.14
import QtQuick.Layouts 1.14
import QtQuick.Controls 2.14
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents2
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kirigami 2.12 as Kirigami
import org.kde.mycroft.bigscreen 1.0 as BigScreen
import org.kde.kdeconnect 1.0
import QtGraphicalEffects 1.14

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
        clip: true

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            bottom: headerAreaSettingsItem.top
            margins: Kirigami.Units.largeSpacing * 2
        }

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: parent.height * 0.20
        }
        
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: parent.height / 3
            Layout.alignment: Qt.AlignTop

            Rectangle {
                id: dIcon
                anchors.top: headrSept.bottom
                anchors.topMargin: Kirigami.Units.largeSpacing
                anchors.horizontalCenter: parent.horizontalCenter
                width: PlasmaCore.Units.iconSizes.huge
                height: width
                radius: 100
                color: Kirigami.Theme.backgroundColor
                
                PlasmaCore.IconItem {
                    id: deviceIconStatus
                    anchors.centerIn: parent
                    width: PlasmaCore.Units.iconSizes.large
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

    RowLayout {
        id: headerAreaSettingsItem
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: Kirigami.Units.largeSpacing * 2
        height: Kirigami.Units.gridUnit * 2

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
            text: i18n("Press the [←] Back button to return to device selection")
            wrapMode: Text.WordWrap
            maximumLineCount: 2
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignRight
        }
    }
}
