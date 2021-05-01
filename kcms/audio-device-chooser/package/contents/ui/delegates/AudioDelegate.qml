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

    implicitWidth: listView.cellWidth * 2
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
            width: Kirigami.Units.iconSizes.huge
            height: width
            y: contentItemLayout.height/2 - deviceAudioSvgIcon.height/2
            source: Icon.name(Volume, Muted, isPlayback ? "audio-volume" : "microphone-sensitivity")
        }
        
        ColumnLayout {
            id: textLayout
            
            anchors {
                left: deviceAudioSvgIcon.right
                right: contentItemLayout.right
                top: deviceAudioSvgIcon.top
                bottom: deviceAudioSvgIcon.bottom
                leftMargin: Kirigami.Units.smallSpacing
            } 
            
            PlasmaComponents.Label {
                id: deviceNameLabel
                Layout.fillWidth: true
                visible: text.length > 0
                elide: Text.ElideRight
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                maximumLineCount: 2
                textFormat: Text.PlainText
                color: Kirigami.Theme.textColor
                text: delegate.isCurrent ? !currentPort ? Description : i18ndc("kcm_audiodevice", "label of device items", "%1 (%2)", currentPort.description, Description) : !currentPort ? Description.split("(")[0] : i18ndc("kcm_audiodevice", "label of device items", "%1 (%2)", currentPort.description, Description).split("(")[0]
            }
        }
        
        Item {
            id: deviceDefaultRepresentationLayout
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.rightMargin: Kirigami.Units.largeSpacing
            anchors.bottomMargin: Kirigami.Units.largeSpacing
                
            PlasmaCore.IconItem {
                id: deviceDefaultIcon
                anchors.centerIn: parent
                width: listView.currentIndex == index && delegate.activeFocus ? Kirigami.Units.iconSizes.medium : Kirigami.Units.iconSizes.smallMedium
                height: listView.currentIndex == index && delegate.activeFocus ? Kirigami.Units.iconSizes.medium : Kirigami.Units.iconSizes.smallMedium
                source: Qt.resolvedUrl("../images/green-tick-thick.svg")
                opacity: PulseObject.default ? 1 : 0
            }
        }
    }
}
