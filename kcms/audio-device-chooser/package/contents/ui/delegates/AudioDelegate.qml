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
import "../code/icon.js" as Icon

PlasmaComponents.ItemDelegate {
    id: delegate
    property bool isPlayback: type.substring(0, 4) == "sink"
    property bool onlyOne: false
    readonly property var currentPort: Ports[ActivePortIndex]
    property string type
    property bool isDefaultDevice: deviceDefaultIcon.visible
    signal setDefault

    property var hasVolume: HasVolume
    property bool volumeWritable: VolumeWritable
    property var muted: Muted
    property var vol: Volume
    property var pObject: PulseObject
    property int focusMarginWidth: listView.currentIndex == index && delegate.activeFocus ? contentLayout.width : contentLayout.width - units.gridUnit

    implicitWidth: isCurrent ? listView.cellWidth * 2 : listView.cellWidth
    implicitHeight: listView.height + Kirigami.Units.largeSpacing

    readonly property ListView listView: ListView.view
    readonly property bool isCurrent: listView.currentIndex == index && activeFocus

    z: isCurrent ? 2 : 0
    
    leftPadding: Kirigami.Units.largeSpacing * 3
    topPadding: Kirigami.Units.largeSpacing * 3
    rightPadding: Kirigami.Units.largeSpacing * 3
    bottomPadding: Kirigami.Units.largeSpacing * 3    

    BigScreen.ImagePalette {
        id: imagePalette
        sourceItem: deviceAudioSvgIcon
        property bool useColors: BigScreen.Hack.coloredTiles
        property color backgroundColor: useColors ? suggestedContrast : PlasmaCore.ColorScope.backgroundColor
        property color accentColor: useColors ? mostSaturated : PlasmaCore.ColorScope.highlightColor
        property color textColor: useColors
            ? (0.2126 * suggestedContrast.r + 0.7152 * suggestedContrast.g + 0.0722 * suggestedContrast.b > 0.6 ? Qt.rgba(0.2,0.2,0.2,1) : Qt.rgba(0.9,0.9,0.9,1))
            : PlasmaCore.ColorScope.textColor

        readonly property bool inView: listView.width - delegate.x - deviceAudioSvgIcon.x < listView.contentX
        onInViewChanged: {
            if (inView) {
                imagePalette.update();
            }
        }
    }
    
    Behavior on implicitWidth {
        NumberAnimation {
            duration: Kirigami.Units.longDuration
            easing.type: Easing.InOutQuad
        }
    }
    
    Keys.onReturnPressed: {
        //PulseObject.default = true;
        listView.currentIndex = index
        deviceSettingDialog.open()
        deviceSettingDialog.forceActiveFocus()
    }
    
    onClicked: {
        listView.currentIndex = index
        deviceSettingDialog.open()
        deviceSettingDialog.forceActiveFocus()
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
        id: contentItemLayout
        
        PlasmaCore.IconItem {
            id: deviceAudioSvgIcon
            width: listView.cellWidth - delegate.leftPadding - (delegate.isCurrent ? 0 : delegate.rightPadding)
            height: isCurrent ? width : width - Kirigami.Units.largeSpacing * 4
            source: Icon.name(Volume, Muted, isPlayback ? "audio-volume" : "microphone-sensitivity")
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
            y: delegate.isCurrent ? contentItemLayout.height / 2 - height / 2 : contentItemLayout.height - (deviceNameLabel.height + deviceDefaultRepresentationLayout.height)
            
            Kirigami.Heading {
                id: deviceNameLabel
                Layout.fillWidth: true
                visible: text.length > 0
                level: 2
                elide: Text.ElideRight
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                maximumLineCount: delegate.isCurrent ? 3 : 2 
                textFormat: Text.PlainText
                color: imagePalette.textColor
                text: delegate.isCurrent ? !currentPort ? Description : i18ndc("kcm_pulseaudio", "label of device items", "%1 (%2)", currentPort.description, Description) : !currentPort ? Description.split("(")[0] : i18ndc("kcm_pulseaudio", "label of device items", "%1 (%2)", currentPort.description, Description).split("(")[0]
            }
            
            RowLayout {
                id: deviceDefaultRepresentationLayout
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                visible: PulseObject.default ? 1 : 0
                
                Kirigami.Icon {
                    id: deviceDefaultIcon
                    Layout.leftMargin: Kirigami.Units.smallSpacing
                    Layout.preferredWidth: listView.currentIndex == index && delegate.activeFocus ? Kirigami.Units.iconSizes.medium : Kirigami.Units.iconSizes.smallMedium
                    Layout.preferredHeight: listView.currentIndex == index && delegate.activeFocus ? Kirigami.Units.iconSizes.medium : Kirigami.Units.iconSizes.smallMedium
                    source: "answer-correct"
                    visible: PulseObject.default ? 1 : 0
                }
                
                Kirigami.Heading {
                    id: deviceDefaultLabel
                    Layout.rightMargin: Kirigami.Units.smallSpacing
                    level: 2
                    text: "Default"
                    visible: PulseObject.default ? 1 : 0
                }
            }
        }
    }

    Popup {
        id: deviceSettingDialog
        parent: Overlay.overlay
        x: Math.round((parent.width - width) / 2)
        y: Math.round((parent.height - height) / 2)
        width: root.width / 3
        height: root.height  / 2
        dim: true
        property color iconBgColorLeft: "#de6262"
        property color iconBgColorRight: "#ffb850"

        background: Item {
            id: popupBg
            property real extraMargin: Math.round(units.gridUnit * 0.5)
            PlasmaCore.FrameSvgItem {
                anchors {
                    fill: framePop
                    leftMargin: -margins.left
                    topMargin: -margins.top
                    rightMargin: -margins.right
                    bottomMargin: -margins.bottom
                }
                imagePath: "dialogs/background"
                prefix: "shadow"
            }
            Rectangle {
                id: framePop
                anchors {
                    fill: parent
                    margins: popupBg.extraMargin
                }
                color: Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 0.95)
            }
        }

        ColumnLayout {
            anchors.margins: Kirigami.Units.largeSpacing
            anchors.fill: parent


            Kirigami.Icon {
                id: devIcon
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: Kirigami.Units.iconSizes.huge
                Layout.preferredHeight: width
                source: Icon.name(Volume, Muted, isPlayback ? "audio-volume" : "microphone-sensitivity")
            }

            Label {
                id: label2
                Layout.alignment: Qt.AlignHCenter
                wrapMode: Text.WordWrap
                maximumLineCount: 2
                elide: Text.ElideRight
                color: PlasmaCore.ColorScope.textColor
                text: Description
            }

            Kirigami.Separator {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                Layout.alignment: Qt.AlignTop
            }

            PlasmaComponents.Button {
                id: setDefBtn
                text: PulseObject.default ? "Is Default" : "Set Default"
                Layout.fillWidth: true
                enabled: PulseObject.default ? 0 : 1
                Layout.preferredHeight: Kirigami.Units.gridUnit * 3
                KeyNavigation.down: volObj
                Keys.onReturnPressed: {
                    PulseObject.default = true;
                    listView.currentIndex = index
                    volObj.forceActiveFocus()
                }
                onClicked:  {
                    PulseObject.default = true;
                    listView.currentIndex = index
                }
                PlasmaComponents2.Highlight {
                    z: -2
                    anchors.fill: parent
                    anchors.margins: -units.gridUnit / 4
                    visible: setDefBtn.activeFocus ? 1 : 0
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.margins: Kirigami.Units.largeSpacing

                VolumeObject {
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

                    KeyNavigation.down: clseBtn
                }

                PlasmaComponents2.Highlight {
                    z: -2
                    anchors.fill: parent
                    anchors.margins: -units.gridUnit / 4
                    visible: volObj.activeFocus ? 1 : 0
                }
            }

            Kirigami.Separator {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
            }

            PlasmaComponents.Button {
                id: clseBtn
                Layout.fillWidth: true
                text: "Close"
                onClicked: deviceSettingDialog.close()
                Keys.onReturnPressed: deviceSettingDialog.close()

                PlasmaComponents2.Highlight {
                    z: -2
                    anchors.fill: parent
                    anchors.margins: -units.gridUnit / 4
                    visible: clseBtn.activeFocus ? 1 : 0
                }
            }
        }

        onOpenedChanged: {
            if(setDefBtn.enabled){
                setDefBtn.forceActiveFocus()
            } else {
                volObj.forceActiveFocus()
            }
        }
        onClosed: delegate.forceActiveFocus()
    }
}
