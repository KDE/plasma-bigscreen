/*
 * Copyright 2020 Aditya Mehra <aix.m@outlook.com>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License or (at your option) version 3 or any later version
 * accepted by the membership of KDE e.V. (or its successor approved
 * by the membership of KDE e.V.), which shall act as a proxy
 * defined in Section 14 of version 3 of the license.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import org.kde.kirigami 2.11 as Kirigami
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.kdeconnect 1.0

Item {
    id: untrustedDevice
    Layout.fillWidth: true
    Layout.fillHeight: true
    
    onActiveFocusChanged: {
        pairBtn.forceActiveFocus()
    }
    
    Timer {
           id: timer
    }

    function delay(delayTime, cb) {
            timer.interval = delayTime;
            timer.repeat = false;
            timer.triggered.connect(cb);
            timer.start();
    }
    
    ColumnLayout {
        anchors.fill: parent
        
        PlasmaComponents.Label {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            text: i18n("This device is not paired")
        }
        
        Button {
            id: pairBtn
            Layout.fillWidth: true
            Layout.preferredHeight: Kirigami.Units.gridUnit * 2
            Kirigami.Theme.colorSet: Kirigami.Theme.Button
            
            Keys.onReturnPressed: {
                clicked()
            }
                
            onClicked: {
                deviceView.currentDevice.requestPair()
                pairRequestNotification.visible = true
                delay(2500, function() {
                    pairRequestNotification.visible = false
                })
            }
                
            KeyNavigation.up: backBtnSettingsItem
        
            background: Rectangle {
                color: pairBtn.activeFocus ? Kirigami.Theme.highlightColor : Kirigami.Theme.backgroundColor
                border.width: 0.75
                border.color: Qt.tint(Kirigami.Theme.textColor, Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 0.8))
            }
            
            contentItem: Item {
                RowLayout {
                    anchors.centerIn: parent
                
                    Kirigami.Icon {
                        Layout.preferredWidth: Kirigami.Units.iconSizes.small
                        Layout.preferredHeight: Kirigami.Units.iconSizes.small
                        source: "network-connect"
                    }
                    
                    PlasmaComponents.Label {
                        text: i18n("Pair")
                    }
                }
            }
        }
        
        PlasmaComponents.Label {
            id: pairRequestNotification
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            visible: false
            text: i18n("Pairing request sent to device")
        }
    }
} 
