/* Copyright 2019 Aditya Mehra <aix.m@outlook.com>                            

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) version 3, or any
    later version accepted by the membership of KDE e.V. (or its
    successor approved by the membership of KDE e.V.), which shall
    act as a proxy defined in Section 6 of version 3 of the license.
    
    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.
    
    You should have received a copy of the GNU Lesser General Public
    License along with this library.  If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.9
import QtQml.Models 2.2
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.kirigami 2.5 as Kirigami
import Mycroft 1.0 as Mycroft

Item {
    id: page
    property alias cfg_websocketAddress: websocketAddress.text
    property alias cfg_notificationSwitch: notificationSwitch.checked
    property alias cfg_enableRemoteTTS: enableRemoteTTS.checked
    property alias cfg_enableRemoteSTT: enableRemoteSTT.checked
    
    Kirigami.FormLayout {
        anchors.left: parent.left
        anchors.right: parent.right
                    
        PlasmaComponents.TextField {
            id: websocketAddress
            Layout.fillWidth: true
            Kirigami.FormData.label: i18n("Websocket Address:")       
            Component.onCompleted: {
                websocketAddress.text = Mycroft.GlobalSettings.webSocketAddress
            }
        }
        
        CheckBox {
            id: notificationSwitch
            Kirigami.FormData.label: i18n ("Additional Settings:")
            text: i18n("Enable Notifications")
            checked: true
        }
        
        CheckBox {
            id: enableRemoteTTS
            text: i18n("Enable Remote TTS")
            checked: Mycroft.GlobalSettings.usesRemoteTTS
            onCheckedChanged: Mycroft.GlobalSettings.usesRemoteTTS = checked
        }
        
        CheckBox {
            id: enableRemoteSTT
            text: i18n("Enable Remote STT")
            checked: false
        }
    }
}

