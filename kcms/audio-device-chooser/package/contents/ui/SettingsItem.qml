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
import org.kde.plasma.private.volume 0.1

import "delegates" as Delegates
import "code/icon.js" as Icon

Rectangle {
    id: delegateSettingsItem
    property bool isPlayback: type.substring(0, 4) == "sink"
    property string type
    readonly property ListView listView: ListView.view
    color: Kirigami.Theme.backgroundColor
    width: listView.width
    height: listView.height

    onActiveFocusChanged: {
        if(activeFocus){
            if(PulseObject.default){
                volObj.forceActiveFocus()
            } else {
                setDefBtn.forceActiveFocus()   
            }
        }
    }
    
    Keys.onBackPressed: {
        backBtnSettingsItem.clicked()
    }

    ColumnLayout {
        id: colLayoutSettingsItem
        anchors {
            fill: parent
            margins: Kirigami.Units.largeSpacing
        }
        
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: parent.height / 3
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
                        if(type == "sink"){
                            sinkView.forceActiveFocus()
                        } else if (type == "source") {
                            sourceView.forceActiveFocus()
                        }
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
                anchors.topMargin: Kirigami.Units.largeSpacing
                width: parent.width
                height: 1
            }
            
            Kirigami.Icon {
                id: dIcon
                anchors.top: headrSept.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width
                height: width / 3
                source: Icon.name(Volume, Muted, isPlayback ? "audio-volume" : "microphone-sensitivity")
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
                text: Description
            }
            
            Kirigami.Separator {
                id: lblSept
                anchors.top: label2.bottom
                anchors.topMargin: Kirigami.Units.largeSpacing
                height: 1
                width: parent.width
            }
            
            Button {
                id: setDefBtn
                //enabled: PulseObject.default ? 1 : 0
                KeyNavigation.up: backBtnSettingsItem
                KeyNavigation.down: volObj
                width: parent.width
                height: Kirigami.Units.gridUnit * 2
                anchors.top: lblSept.bottom
                anchors.topMargin: Kirigami.Units.smallSpacing
                
                Keys.onReturnPressed: {
                    PulseObject.default = true;
                    listView.currentIndex = index
                    volObj.forceActiveFocus()
                }
                
                background: Rectangle {
                    color: setDefBtn.activeFocus ? Kirigami.Theme.highlightColor : Kirigami.Theme.backgroundColor
                }
                
                contentItem: Item {
                    RowLayout {
                        anchors.centerIn: parent
                        PlasmaCore.IconItem {
                            Layout.preferredWidth: Kirigami.Units.iconSizes.medium
                            Layout.preferredHeight: Kirigami.Units.iconSizes.medium
                            source: Qt.resolvedUrl("images/green-tick.svg")
                            enabled: PulseObject.default ? 1 : 0
                        }
//                         Kirigami.Heading {
//                             level: 3
//                             text: PulseObject.default ? "Default" : "Set Default"
//                         }
                    }
                }
                
                onClicked:  {
                    PulseObject.default = true;
                    listView.currentIndex = index
                }
            }
            
            Kirigami.Separator {
                id: lblSept2
                anchors.top: setDefBtn.bottom
                anchors.topMargin: Kirigami.Units.smallSpacing
                height: 1
                width: parent.width
            }
            
            Item {
                anchors.top: lblSept2.bottom
                anchors.topMargin: Kirigami.Units.largeSpacing
                width: parent.width
                height: volObj.height
    
                Delegates.VolumeObject {
                    id: volObj
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter

                    Keys.onRightPressed: {
                        increaseVal()
                    }
                    Keys.onLeftPressed: {
                        decreaseVal()
                    }
                }

                PlasmaComponents2.Highlight {
                    z: -2
                    anchors.fill: parent
                    anchors.margins: -Kirigami.Units.gridUnit / 4
                    visible: volObj.activeFocus ? 1 : 0
                }
            }
        }
        
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: parent.height / 3
        }
    }
}
 
