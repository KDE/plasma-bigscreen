/*
    SPDX-FileCopyrightText: 2019-2020 Aditya Mehra <aix.m@outlook.com>
    SPDX-FileCopyrightText: 2019-2020 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later OR GPL-3.0-or-later OR LicenseRef-KDE-Accepted-GPL
*/

import QtQuick 2.14
import QtQuick.Layouts 1.14
import QtQuick.Controls 2.14
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents2
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kirigami 2.12 as Kirigami
import org.kde.mycroft.bigscreen 1.0 as BigScreen
import QtGraphicalEffects 1.14
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
                    text: i18n("Press the [←] Back button to return to device selection")
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
                            source: Qt.resolvedUrl("images/green-tick-thick.svg")
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
 
