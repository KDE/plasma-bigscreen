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
import org.kde.bigscreen as BigScreen
import "delegates" as Delegates

KCM.SimpleKCM {
    id: root
    
    title: i18n("KDE Connect")
    background: null
    leftPadding: Kirigami.Units.smallSpacing
    topPadding: 0
    rightPadding: Kirigami.Units.smallSpacing
    bottomPadding: 0

    property Item settingMenuItem: networkSelectionView.parent.parent.lastSettingMenuItem

    function settingMenuItemFocus() {
        settingMenuItem.forceActiveFocus()
    }
    
    Component.onCompleted: {
        if(allDevicesModel.count > 0) {
            connectionView.forceActiveFocus();
        } else {
            settingMenuItemFocus();
        }
    }

    DevicesModel {
        id: allDevicesModel
    }

    contentItem: FocusScope {

        Item {
            id: headerAreaTop
            height: parent.height * 0.075
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: Kirigami.Units.largeSpacing

            Kirigami.Heading {
                id: settingsTitle
                text: i18n("KDE Connect")
                anchors.fill: parent
                anchors.margins: Kirigami.Units.largeSpacing
                verticalAlignment: Text.AlignBottom
                horizontalAlignment: Text.AlignLeft
                font.bold: true
                color: Kirigami.Theme.textColor
                fontSizeMode: Text.Fit
                minimumPixelSize: 16
                font.pixelSize: 32
            }
        }

        Kirigami.Separator {
            id: settingsSeparator
            anchors.top: headerAreaTop.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            Kirigami.Theme.colorSet: Kirigami.Theme.Button
            Kirigami.Theme.inherit: false
            color: Kirigami.Theme.backgroundColor
            height: 2
        }

        Item {
            clip: true
            anchors.left: parent.left
            anchors.top: headerAreaTop.bottom
            anchors.bottom: parent.bottom
            width: parent.width - deviceConnectionView.width

            ColumnLayout {
                anchors.fill: parent
                anchors.leftMargin: Kirigami.Units.largeSpacing
                anchors.topMargin: Kirigami.Units.largeSpacing * 2

                BigScreen.TileView {
                    id: connectionView
                    focus: true
                    model:  allDevicesModel
                    Layout.alignment: Qt.AlignTop
                    title: allDevicesModel.count > 0 ? "Found Devices" : "No Devices Found"
                    currentIndex: 0
                    delegate: Delegates.DeviceDelegate{}
                    navigationDown: kcmcloseButton
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

        DeviceConnectionView {
            id: deviceConnectionView
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            visible: allDevicesModel.count > 0 ? 1 : 0
            anchors.rightMargin: -Kirigami.Units.smallSpacing
            width: Kirigami.Units.gridUnit * 15
        }
    }
}
