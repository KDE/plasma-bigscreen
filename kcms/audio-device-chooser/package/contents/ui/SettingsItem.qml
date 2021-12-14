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
import QtGraphicalEffects 1.14
import org.kde.plasma.private.volume 0.1

import "delegates" as Delegates
import "code/icon.js" as Icon

Item {
    id: delegateSettingsItem
    property bool isPlayback: type.substring(0, 4) == "sink"
    property string type
    readonly property var currentPort: Ports[ActivePortIndex]
    readonly property ListView listView: ListView.view
    width: listView.width
    height: listView.height

    onActiveFocusChanged: {
        if(activeFocus){
            if(model.PulseObject.default){
                volObj.forceActiveFocus()
            } else {
                setDefBtn.forceActiveFocus()
            }
        }
    }
    
    Keys.onBackPressed: {
        backBtnSettingsItem.clicked()
    }

    Item {
        id: colLayoutSettingsItem
        clip: true
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            bottom: footerAreaSettingsSept.top
            margins: Kirigami.Units.largeSpacing * 2
        }
        
        Item {
            anchors.centerIn: parent
            width: parent.width
            height: dIcon.height + label1.paintedHeight + label2.paintedHeight + lblSept.height + lblSept2.height + setDefBtn.height + (volObj.height * 2)

            Kirigami.Icon {
                id: dIcon
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width
                height: width / 4
                source: Icon.name(Volume, Muted, isPlayback ? "audio-volume" : "microphone-sensitivity")
            }

            Kirigami.Heading {
                id: label1
                width: parent.width
                anchors.top: dIcon.bottom
                anchors.topMargin: Kirigami.Units.largeSpacing
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                level: 2
                maximumLineCount: 2
                elide: Text.ElideRight
                color: PlasmaCore.ColorScope.textColor
                font.pixelSize: textMetrics.font.pixelSize * 1.25
                text: currentPort.description
            }
            
            Kirigami.Heading {
                id: label2
                width: parent.width
                anchors.top: label1.bottom
                anchors.topMargin: Kirigami.Units.largeSpacing
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                level: 2
                maximumLineCount: 2
                elide: Text.ElideRight
                color: PlasmaCore.ColorScope.textColor
                font.pixelSize: textMetrics.font.pixelSize * 0.9
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
                    model.PulseObject.default = true;
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
                            Layout.preferredWidth: PlasmaCore.Units.iconSizes.medium
                            Layout.preferredHeight: PlasmaCore.Units.iconSizes.medium
                            source: Qt.resolvedUrl("images/green-tick-thick.svg")
                            enabled: model.PulseObject.default  ? 1 : 0
                        }
                    }
                }
                
                onClicked:  {
                    model.PulseObject.default = true;
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

                    Keys.onDownPressed: {
                        backBtnSettingsItem.forceActiveFocus()
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
    }

    Kirigami.Separator {
        id: footerAreaSettingsSept
        anchors.bottom: footerAreaSettingsItem.top
        anchors.bottomMargin: Kirigami.Units.largeSpacing
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: Kirigami.Units.largeSpacing * 2
        anchors.rightMargin: Kirigami.Units.largeSpacing * 2
        height: 1
    }

    RowLayout {
        id: footerAreaSettingsItem
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: Kirigami.Units.largeSpacing * 2
        height: Kirigami.Units.gridUnit * 2

        PlasmaComponents2.Button {
            id: backBtnSettingsItem
            iconSource: "arrow-left"
            Layout.alignment: Qt.AlignLeft
            KeyNavigation.up: volObj

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
}

