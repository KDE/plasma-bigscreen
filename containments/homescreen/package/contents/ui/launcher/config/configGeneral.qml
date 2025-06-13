/*
 * SPDX-FileCopyrightText: 2019 Aditya Mehra <aix.m@outlook.com>
 *
 * SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL
 */


import QtQuick
import QtQml.Models
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.extras as PlasmaExtras
import org.kde.kirigami as Kirigami

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

