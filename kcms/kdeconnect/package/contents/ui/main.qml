/*
 * Copyright 2020 by Aditya Mehra <aix.m@outlook.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

import QtQuick.Layouts 1.4
import QtQuick 2.12
import QtQuick.Window 2.3
import QtQuick.Controls 2.3
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.kirigami 2.8 as Kirigami
import org.kde.kdeconnect 1.0
import org.kde.kcm 1.1 as KCM
import org.kde.mycroft.bigscreen 1.0 as BigScreen
import "delegates" as Delegates

KCM.SimpleKCM {
    id: root
    
    title: i18n("KDE Connect")
    background: null
    
    Component.onCompleted: {
        connectionView.forceActiveFocus();
        console.log(DevicesModel.rowCount);
    }
    
    footer: Button {
        id: kcmcloseButton
        anchors.left: parent.left
        anchors.right: parent.right
        
        background: Rectangle {
            color: kcmcloseButton.activeFocus ? Kirigami.Theme.highlightColor : Kirigami.Theme.backgroundColor
        }
        
        contentItem: Item {
            RowLayout {
                anchors.centerIn: parent
                Kirigami.Icon {
                    Layout.preferredWidth: Kirigami.Units.iconSizes.small
                    Layout.preferredHeight: Kirigami.Units.iconSizes.small
                    source: "window-close"
                }
                Label {
                    text: i18n("Exit")
                }
            }
        } 

        Keys.onUpPressed: root.activateDeviceView()
        
        onClicked: {
            Window.window.close()
        }
        
        Keys.onReturnPressed: {
            Window.window.close()
        }
    }

    DevicesModel {
        id: allDevicesModel
    }
        
    contentItem: FocusScope {
        width: parent.width
        height: parent.height - kcmcloseButton.height
    
        ColumnLayout {
            anchors.left: parent.left
            anchors.leftMargin: Kirigami.Units.largeSpacing
            anchors.top: parent.top
            anchors.topMargin: Kirigami.Units.largeSpacing
            width: parent.width - deviceConnectionView.width
            height: parent.height
        
            BigScreen.TileView {
                id: connectionView
                focus: true
                model:  allDevicesModel
                Layout.alignment: Qt.AlignTop
                title: allDevicesModel.count > 0 ? "Found Devices" : "No Devices Found"
                currentIndex: 0
                delegate: Delegates.DeviceDelegate{}
                Behavior on x {
                    NumberAnimation {
                        duration: Kirigami.Units.longDuration * 2
                        easing.type: Easing.InOutQuad
                    }
                }
                onCurrentItemChanged: {
                    deviceConnectionView.currentDevice = currentItem.deviceObj
                }
            }
        }
                
        DeviceConnectionView {
            id: deviceConnectionView
            anchors.top: parent.top
            anchors.topMargin: -Kirigami.Units.smallSpacing
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            visible: allDevicesModel.count > 0 ? 1 : 0
            anchors.rightMargin: -Kirigami.Units.smallSpacing
            width: parent.width / 3.5
        }
    }
}
