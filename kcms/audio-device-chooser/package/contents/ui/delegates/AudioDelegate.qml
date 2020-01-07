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
import QtGraphicalEffects 1.0
import org.kde.plasma.private.volume 0.1

Item {
    id: delegate
    property bool isPlayback: type.substring(0, 4) == "sink"
    property bool onlyOne: false
    readonly property var currentPort: Ports[ActivePortIndex]
    property string type
    property bool isDefaultDevice: icon.visible
    signal setDefault

    property var hasVolume: HasVolume
    property bool volumeWritable: VolumeWritable
    property var muted: Muted
    property var vol: Volume
    property var pObject: PulseObject

    implicitWidth: listView.cellWidth
    implicitHeight: listView.height + Kirigami.Units.gridUnit * 5

    readonly property ListView listView: ListView.view

    z: listView.currentIndex == index ? 2 : 0

    Keys.onReturnPressed: {
        //PulseObject.default = true;
        listView.currentIndex = index
        deviceSettingDialog.open()
        deviceSettingDialog.forceActiveFocus()
    }

    PlasmaComponents.ItemDelegate {
        id: itemDel
        implicitWidth: listView.cellWidth
        implicitHeight: listView.height + Kirigami.Units.gridUnit * 5

        onClicked: {
            PulseObject.default = true;
            listView.currentIndex = index
        }

        leftPadding: frame.margins.left + background.extraMargin
        topPadding: frame.margins.top + background.extraMargin
        rightPadding: frame.margins.right + background.extraMargin
        bottomPadding: frame.margins.bottom + background.extraMargin

        background: Item {
            id: background
            property real extraMargin:  Math.round(listView.currentIndex == index && delegate.activeFocus ? -units.gridUnit/2 : units.gridUnit/2)
            Behavior on extraMargin {
                NumberAnimation {
                    duration: Kirigami.Units.longDuration
                    easing.type: Easing.InOutQuad
                }
            }

            PlasmaCore.FrameSvgItem {
                anchors {
                    fill: frame
                    leftMargin: -margins.left
                    topMargin: -margins.top
                    rightMargin: -margins.right
                    bottomMargin: -margins.bottom
                }
                imagePath: "dialogs/background"
                prefix: "shadow"
            }
            PlasmaCore.FrameSvgItem {
                id: frame
                anchors {
                    fill: parent
                    margins: background.extraMargin
                }
                imagePath: "dialogs/background"

                width: listView.currentIndex == index && delegate.activeFocus ? parent.width : parent.width - units.gridUnit
                height: listView.currentIndex == index && delegate.activeFocus ? parent.height : parent.height - units.gridUnit
                opacity: 0.8
            }
            PlasmaComponents2.Highlight {
                z: -1
                anchors.fill: parent
                anchors.margins: background.extraMargin
                visible: delegate.activeFocus ? 1 : 0
            }
        }

        contentItem: ColumnLayout {
            spacing: 0
            
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: Kirigami.Units.gridUnit * 2
            }
            
            Kirigami.Heading {
                id: label
                visible: text.length > 0
                level: 2
                Layout.maximumWidth: parent.width
                height: parent.height
                wrapMode: Text.WordWrap
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                maximumLineCount: 3
                elide: Text.ElideRight
                color: PlasmaCore.ColorScope.textColor

                text: !currentPort ? Description : i18ndc("kcm_pulseaudio", "label of device items", "%1 (%2)", currentPort.description, Description)
            }
            
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: Kirigami.Units.gridUnit * 2
            }
            
            Kirigami.Separator {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Kirigami.Theme.textColor
                visible: PulseObject.default ? 1 : 0
            }

            Kirigami.Icon {
                id: icon
                Layout.preferredWidth: Kirigami.Units.iconSizes.large
                Layout.preferredHeight: Kirigami.Units.iconSizes.large
                Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom
                source: "answer-correct"
                visible: PulseObject.default ? 1 : 0
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
                source: "audio-card"
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
