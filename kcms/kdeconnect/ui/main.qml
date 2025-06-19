/*
    SPDX-FileCopyrightText: 2020 Aditya Mehra <aix.m@outlook.com>

    SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL

*/

import QtQuick.Layouts
import QtQuick
import QtQuick.Window
import QtQuick.Controls
import org.kde.kirigami as Kirigami
import org.kde.kdeconnect
import org.kde.kcmutils as KCM
import org.kde.bigscreen as Bigscreen
import "delegates" as Delegates

KCM.SimpleKCM {
    id: root
    
    title: i18n("KDE Connect")
    background: null
    leftPadding: Kirigami.Units.smallSpacing
    topPadding: 0
    rightPadding: Kirigami.Units.smallSpacing
    bottomPadding: 0

    Component.onCompleted: {
        connectionView.forceActiveFocus();
    }

    DevicesModel {
        id: allDevicesModel
    }

    contentItem: FocusScope {
        Item {
            clip: true
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: parent.width - deviceConnectionView.width

            ColumnLayout {
                anchors.fill: parent
                anchors.leftMargin: Kirigami.Units.largeSpacing
                anchors.topMargin: Kirigami.Units.largeSpacing * 2

                Bigscreen.TileView {
                    id: connectionView
                    focus: true
                    model:  allDevicesModel
                    Layout.alignment: Qt.AlignTop
                    title: allDevicesModel.count > 0 ? "Found Devices" : "No Devices Found"
                    currentIndex: 0
                    delegate: Delegates.DeviceDelegate {}
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
        }

        Kirigami.Separator {
            id: viewSept
            anchors.right: deviceConnectionView.left
            anchors.top: deviceConnectionView.top
            anchors.bottom: deviceConnectionView.bottom
            width: 1
        }

        DeviceConnectionView {
            id: deviceConnectionView
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            visible: allDevicesModel.count > 0 ? 1 : 0
            anchors.rightMargin: -Kirigami.Units.smallSpacing
            width: Kirigami.Units.gridUnit * 15
            Keys.onLeftPressed: connectionView.forceActiveFocus()
            Keys.onEscapePressed: connectionView.forceActiveFocus()
        }
    }
}
