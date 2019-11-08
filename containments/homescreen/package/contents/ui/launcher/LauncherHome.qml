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
    anchors {
        fill: parent
        margins: units.smallSpacing * 2
    }
    
    ColumnLayout {
        id: launcherHomeColumn
        anchors.fill: parent
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
            model: plasmoid.nativeInterface.voiceAppListModel
            currentIndex: 0
            focus: true
            delegate: Delegates.VoiceAppDelegate {
                property var modelData: typeof model !== "undefined" ? model : null
                
            }

            navigationUp: shutdownIndicator
            navigationDown: gridView2
        }

        Views.ColumnLabelView {
            id: appsColumnLabelBox
            text: "My Apps & Games"  
        }

        Views.TileView {
            id: gridView2
            model: plasmoid.nativeInterface.applicationListModel
            currentIndex: 0
            focus: false
            delegate: Delegates.AppDelegate {
                property var modelData: typeof model !== "undefined" ? model : null
            }
            
            navigationUp: gridView
            navigationDown: gridView3
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
                ListElement { name: "Wallpaper"; icon: "preferences-desktop-wallpaper"}
                ListElement { name: "Mycroft"; icon: "mycroft"}
            }

            delegate: Delegates.SettingDelegate {
                property var modelData: typeof model !== "undefined" ? model : null
            }
            
            navigationUp: gridView2
            navigationDown: null
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

