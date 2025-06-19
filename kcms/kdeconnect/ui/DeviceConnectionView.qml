/*
    SPDX-FileCopyrightText: 2020 Aditya Mehra <aix.m@outlook.com>
    SPDX-FileCopyrightText: 2015 Aleix Pol Gonzalez <aleixpol@kde.org>

    SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami
import org.kde.bigscreen as Bigscreen
import org.kde.kdeconnect
import Qt5Compat.GraphicalEffects

import "delegates" as Delegates

Rectangle {
    id: deviceView
    color: Kirigami.Theme.backgroundColor
    property QtObject currentDevice
    property bool isPairRequested: currentDevice.isPairRequested
    property bool isPaired: currentDevice.isPaired
    property bool isReachable: currentDevice.isReachable
    
    onCurrentDeviceChanged: checkCurrentStatus()
    
    onIsPairRequestedChanged: {
        if(isPairRequested) {
            checkCurrentStatus()
        }
    }
    
    onIsPairedChanged: checkCurrentStatus()
    onIsReachableChanged: checkCurrentStatus()
    
    onActiveFocusChanged: {
        if (activeFocus) {
            deviceStackLayout.forceActiveFocus()
        }
    }
    
    function checkCurrentStatus() {
        //if (currentDevice.isPairRequested) {
        //    deviceStackLayout.currentIndex = 1
        //} else
        // disable pairing request handler in kcm as indicator handles pairing in bigscreen
        
        if (currentDevice.isReachable) {
            if (currentDevice.isPaired) {
                deviceIconStatus.source = currentDevice.statusIconName
                deviceStackLayout.currentIndex = 2
                
            } else {
                deviceIconStatus.source = currentDevice.iconName
                deviceStackLayout.currentIndex = 0
            }
            
        } else {
            deviceStackLayout.currentIndex = 3
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
                id: deviceIcon
                anchors.bottom: deviceIconSept.bottom
                anchors.bottomMargin: Kirigami.Units.largeSpacing
                anchors.horizontalCenter: parent.horizontalCenter
                width: Kirigami.Units.iconSizes.huge
                height: width
                radius: 100
                color: Kirigami.Theme.backgroundColor
                
                Kirigami.Icon {
                    id: deviceIconStatus
                    anchors.centerIn: parent
                    width: Kirigami.Units.iconSizes.large
                    height: width
                    source: currentDevice.iconName
                }
            }

            Kirigami.Separator {
                id: deviceIconSept
                anchors.top: deviceIcon.bottom
                anchors.topMargin: Kirigami.Units.smallSpacing
                anchors.bottomMargin: Kirigami.Units.smallSpacing
                height: 1
                width: parent.width
            }
            
            Kirigami.Heading {
                id: deviceLabel
                width: parent.width
                anchors.top: deviceIconSept.bottom
                anchors.topMargin: Kirigami.Units.largeSpacing
                anchors.bottomMargin: Kirigami.Units.largeSpacing
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                level: 2
                maximumLineCount: 2
                elide: Text.ElideRight
                color: Kirigami.Theme.textColor
                text: currentDevice.name
                font.bold: true
            }

            Kirigami.Separator {
                id: deviceLabelSept
                anchors.top: deviceLabel.bottom
                anchors.topMargin: Kirigami.Units.mediumSpacing
                height: 1
                width: parent.width
            }
            
            StackLayout {
                id: deviceStackLayout
                anchors.top: deviceLabelSept.bottom
                anchors.topMargin: Kirigami.Units.largeSpacing
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom

                onActiveFocusChanged: {
                    if (activeFocus) {
                        children[currentIndex].forceActiveFocus()
                    }
                }

                onCurrentIndexChanged: {
                    connectionView.forceActiveFocus()
                }
                
                Delegates.UnpairedView { id: unpairedView }
                
                Delegates.PairRequest { id: pairRequestView }
                
                Delegates.PairedView { id: pairedView }
                
                Delegates.Unreachable{ id: unreachableView }
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
    }
}
