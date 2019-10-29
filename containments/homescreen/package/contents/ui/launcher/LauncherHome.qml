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
import "views" as Views

FocusScope {
    anchors.fill: parent
    
    ColumnLayout {
        id: launcherHomeColumn
        width: parent.width
        height: parent.height
        spacing: 1
        property Component activeHighlightItem: PlasmaComponents.Highlight{}
        property Component disabledHighlightItem: Item {}
        property alias columnLabelHeight: voiceAppsLabelColumnBox.height
        
        Views.ColumnLabelView {
            id: voiceAppsLabelColumnBox
            text: "My Voice Apps"  
        }
                
        Views.TileView {
            id: gridView
            model: root.voiceAppsModel
            currentIndex: 0
            focus: true
            delegate: Delegates.VoiceAppDelegate {
                property var modelData: typeof model !== "undefined" ? model : null
            }
            
            Keys.onReturnPressed: {
                if (gridView.focus) {
                    root.voiceAppsModel.moveItem(currentIndex, 0)
                    root.appsModel.runApplication(gridView.appId)
                    gridView.forceActiveFocus()
                    lastItemIndex = gridView.currentIndex
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
            }
            
            Keys.onLeftPressed: {
                if (gridView.currentIndex == 0) {
                    gridView.currentIndex = gridView.count -1
                } else {
                    gridView.positionViewAtIndex(gridView.currentIndex-1, GridView.Center)
                    gridView.currentIndex = gridView.currentIndex - 1
                }
                lastItemIndex = gridView.currentIndex
            }
            
            Keys.onUpPressed: { 
                activateTopNavBar()
            }
            
            Keys.onDownPressed: {
                gridView2.forceActiveFocus()
                gridView.focus = false
            }
            
            onCurrentItemChanged: {
                gridView.appId = currentItem.vAppStorageIdRole
            }
        }

        Views.ColumnLabelView {
            id: appsColumnLabelBox
            text: "My Apps & Games"  
        }
        

        Views.TileView {
            id: gridView2
            model: root.appsModel
            currentIndex: 0
            focus: false
            delegate: Delegates.AppDelegate {
                property var modelData: typeof model !== "undefined" ? model : null
            }
            
            Keys.onReturnPressed: {
                if (gridView2.focus) {
                    root.appsModel.moveItem(currentIndex, 0)
                    root.appsModel.runApplication(gridView2.appId)
                    gridView2.forceActiveFocus()
                    lastItemIndex = gridView2.currentIndex
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
            }
            Keys.onLeftPressed:  { 
                if (gridView2.currentIndex == 0) {
                    gridView2.currentIndex = gridView2.count -1
                } else {
                    gridView2.positionViewAtIndex(gridView2.currentIndex-1, GridView.Center)
                    gridView2.currentIndex = gridView2.currentIndex - 1
                }
                lastItemIndex = gridView2.currentIndex
            }
            Keys.onUpPressed:    { 
                gridView.forceActiveFocus()
                gridView.currentIndex = gridView.lastItemIndex
                gridView2.focus = false
            }
            Keys.onDownPressed:  {  
                gridView3.forceActiveFocus()
                gridView2.focus = false
            }
            
            onCurrentItemChanged: {
                gridView2.appId = currentItem.appStorageIdRole
            }
        }
        
        Views.ColumnLabelView {
            id: settingsLabelColumnBox
            text: "My Settings"  
        }
                    
        Views.TileView {
            id: gridView3
            model: ListModel {
            ListElement { name: "Wireless"; icon: "network-wireless-connected-100"}
            ListElement { name: "Preferences"; icon: "dialog-scripts"}
            ListElement { name: "Mycroft"; icon: "mycroft"}
            }
            focus: false
            delegate: Delegates.SettingDelegate {
                property var modelData: typeof model !== "undefined" ? model : null
            }
                                
            Keys.onEnterPressed: {
                if (gridView3.focus) {
                    root.appsModel.runApplication(gridView2.appId)
                }
            }
            
            Keys.onReturnPressed: {
                if (gridView3.focus) {
                    console.log("Not Implemented")
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
            }
            Keys.onLeftPressed:  { 
                if (gridView3.currentIndex == 0) {
                    gridView3.currentIndex = gridView3.count -1
                } else {
                    gridView3.positionViewAtIndex(gridView3.currentIndex-1, GridView.Center)
                    gridView3.currentIndex = gridView3.currentIndex - 1
                }
                lastItemIndex = gridView3.currentIndex
            }
            Keys.onUpPressed:    { 
                gridView2.forceActiveFocus()
                gridView2.currentIndex = gridView2.lastItemIndex
                gridView3.focus = false
            }
        }

        Component.onCompleted: {
            gridView.forceActiveFocus();
        }

        Connections {
        target: root
        onActivateAppView: {
            gridView.forceActiveFocus();
            }
        }
    }
}

