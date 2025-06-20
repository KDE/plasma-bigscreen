/*
    SPDX-FileCopyrightText: 2020 Aditya Mehra <aix.m@outlook.com>

    SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami
import org.kde.kdeconnect

Item {
    id: trustedDevice
    Layout.fillWidth: true
    Layout.fillHeight: true
    
    onActiveFocusChanged: {
        unpairBtn.forceActiveFocus()
    }

    ColumnLayout {
        anchors.fill: parent
        
        PlasmaComponents.Label {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            text: i18n("This device is paired")
        }
        
        Button {
            id: unpairBtn
            Layout.fillWidth: true
            Layout.preferredHeight: Kirigami.Units.gridUnit * 2
            Kirigami.Theme.colorSet: Kirigami.Theme.Button
            
            Keys.onReturnPressed: {
                clicked()
            }
            
            onClicked: deviceView.currentDevice.unpair()
            
            background: Rectangle {
                color: unpairBtn.activeFocus ? Kirigami.Theme.highlightColor : Kirigami.Theme.backgroundColor
                border.width: 0.75
                border.color: Qt.tint(Kirigami.Theme.textColor, Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 0.8))
            }
            
            contentItem: Item {
                RowLayout {
                    anchors.centerIn: parent
                
                    Kirigami.Icon {
                        Layout.preferredWidth: PlasmaCore.Units.iconSizes.small
                        Layout.preferredHeight: PlasmaCore.Units.iconSizes.small
                        source: "network-disconnect"
                    }
                    PlasmaComponents.Label {
                        text: i18n("Unpair")
                    }
                }
            }
        }
    }
} 
