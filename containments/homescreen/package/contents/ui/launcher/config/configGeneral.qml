/* SPDX-FileCopyrightText: 2019 Aditya Mehra <aix.m@outlook.com>

    SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL
*/


import QtQuick 2.14
import QtQml.Models 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.kirigami 2.12 as Kirigami

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
            text: cfg_websocketAddress
        }
        
        CheckBox {
            id: notificationSwitch
            Kirigami.FormData.label: i18n("Additional Settings:")
            text: i18n("Enable Notifications")
            checked: true
        }
        
        CheckBox {
            id: enableRemoteTTS
            text: i18n("Enable Remote TTS")
        }
        
        CheckBox {
            id: enableRemoteSTT
            text: i18n("Enable Remote STT")
            checked: false
        }
    }
}

