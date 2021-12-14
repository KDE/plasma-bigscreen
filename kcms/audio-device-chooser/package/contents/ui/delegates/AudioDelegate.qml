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

    implicitWidth: listView.cellWidth * 2.5
    implicitHeight: listView.height + Kirigami.Units.largeSpacing
    
    Behavior on implicitWidth {
        NumberAnimation {
            duration: Kirigami.Units.longDuration
            easing.type: Easing.InOutQuad
        }
    }
    
    Keys.onReturnPressed: {
        listView.currentIndex = index
        settingsViewDetails.currentItem.forceActiveFocus()
    }
    
    onClicked: {
        listView.currentIndex = index
        settingsViewDetails.forceActiveFocus()
    }

    contentItem: Item {
        id: contentItemLayout
        
        PlasmaCore.IconItem {
            id: deviceAudioSvgIcon
            width: PlasmaCore.Units.iconSizes.huge
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
                id: deviceTypeLabel
                Layout.fillWidth: true
                visible: text.length > 0
                elide: Text.ElideRight
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                maximumLineCount: 2
                textFormat: Text.PlainText
                color: Kirigami.Theme.textColor
                font.pixelSize: textMetrics.font.pixelSize * 1
                text: currentPort.description
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
                font.pixelSize: textMetrics.font.pixelSize * 0.8
                text: Description
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
                width: listView.currentIndex == index && delegate.activeFocus ? PlasmaCore.Units.iconSizes.medium : PlasmaCore.Units.iconSizes.smallMedium
                height: listView.currentIndex == index && delegate.activeFocus ? PlasmaCore.Units.iconSizes.medium : PlasmaCore.Units.iconSizes.smallMedium
                source: Qt.resolvedUrl("../images/green-tick-thick.svg")
                opacity: model.PulseObject.default ? 1 : 0
            }
        }
    }
}
