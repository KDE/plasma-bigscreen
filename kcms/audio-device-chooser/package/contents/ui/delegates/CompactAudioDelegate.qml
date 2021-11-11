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
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
                maximumLineCount: delegate.isCurrent ? 3 : 2 
                textFormat: Text.PlainText
                color: Kirigami.Theme.textColor
                text: delegate.isCurrent ? !currentPort ? Description : i18ndc("kcm_audiodevice", "label of device items", "%1 (%2)", currentPort.description, Description) : !currentPort ? Description.split("(")[0] : i18ndc("kcm_audiodevice", "label of device items", "%1 (%2)", currentPort.description, Description).split("(")[0]
            }
            
            RowLayout {
                id: deviceDefaultRepresentationLayout
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                
                PlasmaCore.IconItem {
                    id: deviceDefaultIcon
                    Layout.leftMargin: Kirigami.Units.smallSpacing
                    Layout.preferredWidth: listView.currentIndex == index && delegate.activeFocus ? PlasmaCore.Units.iconSizes.medium : PlasmaCore.Units.iconSizes.smallMedium
                    Layout.preferredHeight: listView.currentIndex == index && delegate.activeFocus ? PlasmaCore.Units.iconSizes.medium : PlasmaCore.Units.iconSizes.smallMedium
                    source: Qt.resolvedUrl("../images/green-tick.svg")
                    opacity: PulseObject.default ? 1 : 0
                }
                
//                 Kirigami.Heading {
//                     id: deviceDefaultLabel
//                     Layout.rightMargin: Kirigami.Units.smallSpacing
//                     level: 2
//                     text: i18n("Default")
//                     visible: PulseObject.default ? 1 : 0
//                 }
            }
        }
    }
}
 
