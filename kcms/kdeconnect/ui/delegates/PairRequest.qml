/*
    SPDX-FileCopyrightText: 2019 Aditya Mehra <aix.m@outlook.com>

    SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami
import org.kde.kdeconnect

Item {
    id: pairDevice
    Layout.fillWidth: true
    Layout.fillHeight: true
    
    onActiveFocusChanged: {
        acceptBtn.forceActiveFocus()
    }

    ColumnLayout {
        anchors.fill: parent
        
        PlasmaComponents.Label {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            text: i18n("This device is requesting to be paired")
        }
        
        Button {
            id: acceptBtn
            Layout.fillWidth: true
            Layout.preferredHeight: Kirigami.Units.gridUnit * 2
            Kirigami.Theme.colorSet: Kirigami.Theme.Button
            
            KeyNavigation.up: backBtnSettingsItem
            KeyNavigation.down: rejectBtn
            
            Keys.onReturnPressed: {
                clicked()
            }
            
            onClicked: deviceView.currentDevice.acceptPairing()
            
            background: Rectangle {
                color: acceptBtn.activeFocus ? Kirigami.Theme.highlightColor : Kirigami.Theme.backgroundColor
                border.width: 0.75
                border.color: Qt.tint(Kirigami.Theme.textColor, Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 0.8))
            }
            
            contentItem: Item {
                RowLayout {
                    anchors.centerIn: parent
                
                    Kirigami.Icon {
                        Layout.preferredWidth: Kirigami.Units.iconSizes.small
                        Layout.preferredHeight: Kirigami.Units.iconSizes.small
                        source: "dialog-ok"
                    }
                    PlasmaComponents.Label {
                        text: i18n("Accept")
                    }
                }
            }
        }
        
        Button {
            id: rejectBtn
            Layout.fillWidth: true
            Layout.preferredHeight: Kirigami.Units.gridUnit * 2
            Kirigami.Theme.colorSet: Kirigami.Theme.Button
            
            KeyNavigation.up: acceptBtn
            
            Keys.onReturnPressed: {
                clicked()
            }
            
            onClicked: deviceView.currentDevice.rejectPairing()
            
            background: Rectangle {
                color: rejectBtn.activeFocus ? Kirigami.Theme.highlightColor : Kirigami.Theme.backgroundColor
                border.width: 0.75
                border.color: Qt.tint(Kirigami.Theme.textColor, Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 0.8))
            }
            
            contentItem: Item {
                RowLayout {
                    anchors.centerIn: parent
                
                    Kirigami.Icon {
                        Layout.preferredWidth: Kirigami.Units.iconSizes.small
                        Layout.preferredHeight: Kirigami.Units.iconSizes.small
                        source: "dialog-cancel"
                    }
                    PlasmaComponents.Label {
                        text: i18n("Reject")
                    }
                }
            }
        }
    }
} 
