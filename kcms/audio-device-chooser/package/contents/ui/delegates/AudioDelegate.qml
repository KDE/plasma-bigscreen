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

BigScreen.AbstractDelegate {
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
    property int focusMarginWidth: listView.currentIndex == index && delegate.activeFocus ? contentLayout.width : contentLayout.width - Kirigami.Units.gridUnit

    implicitWidth: isCurrent ? listView.cellWidth * 2 : listView.cellWidth
    implicitHeight: listView.height + Kirigami.Units.largeSpacing
    
    Behavior on implicitWidth {
        NumberAnimation {
            duration: Kirigami.Units.longDuration
            easing.type: Easing.InOutQuad
        }
    }
    
    Keys.onReturnPressed: {
        listView.currentIndex = index
        settingsView.currentItem.forceActiveFocus()
    }
    
    onClicked: {
        listView.currentIndex = index
        settingsView.forceActiveFocus()
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
            width: isCurrent ? listView.cellWidth - delegate.leftPadding : listView.cellWidth - delegate.leftPadding -  delegate.rightPadding 
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
                color: Kirigami.Theme.textColor
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
                    source: Qt.resolvedUrl("../images/green-tick.png")
                    visible: PulseObject.default ? 1 : 0
                }
                
//                 Kirigami.Heading {
//                     id: deviceDefaultLabel
//                     Layout.rightMargin: Kirigami.Units.smallSpacing
//                     level: 2
//                     text: "Default"
//                     visible: PulseObject.default ? 1 : 0
//                 }
            }
        }
    }
}
