/*
 * Copyright 2019 Aditya Mehra <aix.m@outlook.com>
 * Copyright 2015 Marco Martin <mart@kde.org>
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
import QtQuick.Controls 2.3 as Controls
import QtQuick.Window 2.2
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.kquickcontrolsaddons 2.0
import org.kde.private.biglauncher 1.0 as Launcher
import org.kde.kirigami 2.5 as Kirigami

import "delegates" as Delegates

ColumnLayout {
    id: launcherHomeColumn
    anchors.fill: parent
    spacing: 1
    property Component activeHighlightItem: PlasmaComponents.Highlight{}
    property Component disabledHighlightItem: Item {}
    
    Rectangle {
	id: voiceAppsLabelColumnBox
        Layout.preferredWidth: appslabel.contentWidth + Kirigami.Units.largeSpacing * 3
        Layout.preferredHeight: Kirigami.Units.iconSizes.small
        color: Kirigami.Theme.backgroundColor
        
        PlasmaComponents.Label {
            id: appslabel
            anchors.centerIn: parent
            text: "My Voice Apps"
            font.pointSize: Kirigami.Units.iconSizes.small - Kirigami.Units.largeSpacing
            font.capitalization: Font.SmallCaps
        }
    }
    
    Item {
        Layout.fillWidth: true
        Layout.preferredHeight: parent.height / 3 - voiceAppsLabelColumnBox.height
        
        FocusScope {
            anchors.fill: parent
            
            GridView {
                id: gridView
                layoutDirection: Qt.LeftToRight
                width: parent.width
                height: parent.height
                flow: GridView.FlowTopToBottom
                cellWidth: gridView.width / 3
                cellHeight: gridView.height / 1
                model: root.voiceAppsModel
                clip: true
                highlight: gridView.focus == true ? launcherHomeColumn.activeHighlightItem : launcherHomeColumn.disabledHighlightItem
                focus: true
                keyNavigationEnabled: true
                currentIndex: 0
                property var vAppId
                property int lastItemIndex
                delegate: Delegates.VoiceAppDelegate {
                    property var modelData: typeof model !== "undefined" ? model : null
                }
                
                move: Transition {
                    NumberAnimation { properties: "x,y"; duration: 1000 }
                }
                
                Keys.onEnterPressed: {
                    console.log("Enter Pressed In GridView1")
                    if (gridView.focus) {
                         root.appsModel.runApplication(gridView.appId)
                    }
                }
                
                Keys.onReturnPressed: {
                    console.log("Enter Pressed In GridView1")
                    if (gridView.focus) {
                         root.voiceAppsModel.moveItem(currentIndex, 0)
                         root.appsModel.runApplication(gridView.vAppId)
                    }
                }
                
                Keys.onRightPressed: {
                    if (gridView.currentIndex < gridView.count) {
                        gridView.positionViewAtIndex(gridView.currentIndex+1, GridView.Center)
                        gridView.currentIndex = Math.min(gridView.currentIndex+1, gridView.count)
                    } 
                    if(gridView.currentIndex == gridView.count) {
                        gridView.currentIndex = 0
                    }
                    lastItemIndex = gridView.currentIndex
                    console.log("RightKey Pressed")
                }
                
                Keys.onLeftPressed: {
                    if (gridView.currentIndex == 0) {
                        gridView.currentIndex = gridView.count -1
                    } else {
                        gridView.positionViewAtIndex(gridView.currentIndex-1, GridView.Center)
                        gridView.currentIndex = gridView.currentIndex - 1
                    }
                    lastItemIndex = gridView.currentIndex
                    console.log("LeftKey Pressed")
                }
                
                Keys.onUpPressed: { 
                    console.log("UpKey Pressed")
                    activateTopNavBar()
                }
                
                Keys.onDownPressed: { 
                    gridView2.enabled = true
                    gridView2.forceActiveFocus()
                    gridView.focus = false
                }
                
                onCurrentItemChanged: {
                    console.log(currentIndex)
                    gridView.vAppId = currentItem.vAppStorageIdRole
                }
            }
        }
    }
    
    Rectangle {
	id: appsColumnLabelBox
        Layout.preferredWidth: appslabel.contentWidth + Kirigami.Units.largeSpacing * 3
        Layout.preferredHeight: Kirigami.Units.iconSizes.small
        color: Kirigami.Theme.backgroundColor
        
        PlasmaComponents.Label {
            id: appslabel2
            anchors.centerIn: parent
            text: "My Apps & Games"
            font.pointSize: Kirigami.Units.iconSizes.small - Kirigami.Units.largeSpacing
            font.capitalization: Font.SmallCaps
        }
    }
    
    Item {
        Layout.fillWidth: true
        Layout.preferredHeight: parent.height / 3 - appsColumnLabelBox.height
        
        FocusScope {
            anchors.fill: parent
            
            GridView {
                id: gridView2
                layoutDirection: Qt.LeftToRight
                width: parent.width
                height: parent.height
                flow: GridView.FlowTopToBottom
                cellWidth: gridView2.width / 3
                cellHeight: gridView2.height / 1
                model: root.appsModel
                clip: true
                highlight: gridView2.focus == true ? launcherHomeColumn.activeHighlightItem : launcherHomeColumn.disabledHighlightItem
                focus: false
                keyNavigationEnabled: true
                currentIndex: 0
                enabled: false
                property var appId
                property int lastItemIndex
                delegate: Delegates.AppDelegate {
                    property var modelData: typeof model !== "undefined" ? model : null
                }
                
                move: Transition {
                    NumberAnimation { properties: "x,y"; duration: 1000 }
                }
                
                Keys.onEnterPressed: {
                    console.log("Enter Pressed In GridView2")
                    if (gridView2.focus) {
                         root.appsModel.runApplication(gridView2.vAppId)
                    }
                }
                
                Keys.onReturnPressed: {
                    console.log("Enter Pressed In GridView2")
                    if (gridView2.focus) {
                         root.appsModel.moveItem(currentIndex, 0)
                         root.appsModel.runApplication(gridView2.appId)
                    }
                }
                
                Keys.onRightPressed: {
                    if (gridView2.currentIndex < gridView2.count) {
                        gridView2.positionViewAtIndex(gridView2.currentIndex+1, GridView.Center)
                        gridView2.currentIndex = Math.min(gridView2.currentIndex+1, gridView2.count)
                    } 
                    if(gridView2.currentIndex == gridView2.count) {
                        gridView2.currentIndex = 0
                    }
                    lastItemIndex = gridView2.currentIndex
                    console.log("RightKey Pressed")
                }
                Keys.onLeftPressed:  { 
                    if (gridView2.currentIndex == 0) {
                        gridView2.currentIndex = gridView2.count -1
                    } else {
                        gridView2.positionViewAtIndex(gridView2.currentIndex-1, GridView.Center)
                        gridView2.currentIndex = gridView2.currentIndex - 1
                    }
                    lastItemIndex = gridView2.currentIndex
                    console.log("LeftKey Pressed")
                }
                Keys.onUpPressed:    { 
                    gridView.forceActiveFocus()
                    gridView.currentIndex = gridView.lastItemIndex
                    //gridView2.currentIndex = -1
                    gridView2.focus = false
                }
                Keys.onDownPressed:  {  
                    gridView3.forceActiveFocus()
                    gridView2.focus = false
                }
                
                onCurrentItemChanged: {
                    console.log(currentIndex)
                    gridView2.appId = currentItem.appStorageIdRole
                }
            }
        }
    }
    
    Rectangle {
        id: settingsLabelColumnBox
        Layout.preferredWidth: appslabel.contentWidth + Kirigami.Units.largeSpacing * 3
        Layout.preferredHeight: Kirigami.Units.iconSizes.small
        color: Kirigami.Theme.backgroundColor
        
        PlasmaComponents.Label {
            id: appslabel3
            anchors.centerIn: parent
            text: "My Settings"
            font.pointSize: Kirigami.Units.iconSizes.small - Kirigami.Units.largeSpacing
            font.capitalization: Font.SmallCaps
        }
    }
    
    
    Item {
        Layout.fillWidth: true
        Layout.preferredHeight: parent.height / 3 - voiceAppsLabelColumnBox.height
        
        FocusScope {
            anchors.fill: parent
            
            GridView {
                id: gridView3
                layoutDirection: Qt.LeftToRight
                width: parent.width
                height: parent.height
                flow: GridView.FlowTopToBottom
                cellWidth: gridView3.width / 3
                cellHeight: gridView3.height / 1
                model: ListModel {
                ListElement { name: "Wireless"; icon: "network-wireless-connected-100"}
                ListElement { name: "Preferences"; icon: "dialog-scripts"}
                ListElement { name: "Mycroft"; icon: "mycroft"}
                }
                clip: true
                highlight: gridView3.focus == true ? launcherHomeColumn.activeHighlightItem : launcherHomeColumn.disabledHighlightItem
                focus: false
                keyNavigationEnabled: true
                currentIndex: 0
                property int lastItemIndex
                delegate: Delegates.SettingDelegate {
                    property var modelData: typeof model !== "undefined" ? model : null
                }
                
                move: Transition {
                    NumberAnimation { properties: "x,y"; duration: 1000 }
                }
                
                Keys.onEnterPressed: {
                    console.log("Enter Pressed In GridView3")
                    if (gridView3.focus) {
                         root.appsModel.runApplication(gridView2.vAppId)
                    }
                }
                
                Keys.onReturnPressed: {
                    console.log("Enter Pressed In GridView3")
                    if (gridView3.focus) {
                        console.log("setting icon pressed")
                    }
                }
                
                Keys.onRightPressed: {
                    if (gridView3.currentIndex < gridView3.count) {
                        gridView3.positionViewAtIndex(gridView3.currentIndex+1, GridView.Center)
                        gridView3.currentIndex = Math.min(gridView3.currentIndex+1, gridView3.count)
                    } 
                    if(gridView3.currentIndex == gridView3.count) {
                        gridView3.currentIndex = 0
                    }
                    lastItemIndex = gridView3.currentIndex
                    console.log("RightKey Pressed")
                }
                Keys.onLeftPressed:  { 
                    if (gridView3.currentIndex == 0) {
                        gridView3.currentIndex = gridView3.count -1
                    } else {
                        gridView3.positionViewAtIndex(gridView3.currentIndex-1, GridView.Center)
                        gridView3.currentIndex = gridView3.currentIndex - 1
                    }
                    lastItemIndex = gridView3.currentIndex
                    console.log("LeftKey Pressed")
                }
                Keys.onUpPressed:    { 
                    gridView2.forceActiveFocus()
                    gridView3.focus = false
                }
                Keys.onDownPressed:  {  
                    console.log("DownKey Pressed")
                }
                
                onCurrentItemChanged: {
                    console.log(currentIndex)
                }
            }
        }
    }

    Component.onCompleted: {
        gridView.forceActiveFocus();
    }

    Connections {
	target: root
	onActivateAppView: {
	     console.log("here");
	     gridView.forceActiveFocus();
        }
    }
}

