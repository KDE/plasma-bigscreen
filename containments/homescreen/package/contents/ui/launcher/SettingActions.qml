/*
    SPDX-FileCopyrightText: 2019 Aditya Mehra <aix.m@outlook.com>
    SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.14
import QtQuick.Controls 2.14 as Controls

Item {
    id: settingActions

    property list<Controls.Action> actionWithoutIntegration: [
        Controls.Action {
            text: i18n("Audio")
            icon.name: "audio-volume-high"
            onTriggered: plasmoid.nativeInterface.executeCommand("plasma-settings -s -m kcm_audiodevice")
            property bool active: true
        },
        Controls.Action {
            text: i18n("Bigscreen Settings")
            icon.name: "view-grid-symbolic"
            onTriggered: plasmoid.nativeInterface.executeCommand("plasma-settings -s -m kcm_mediacenter_bigscreen_settings")
            property bool active: true
        },
        Controls.Action {
            text: i18n("Wallpaper")
            icon.name: "preferences-desktop-wallpaper"
            onTriggered: plasmoid.action("configure").trigger();
            property bool active: true
        },
        Controls.Action {
            text: i18n("Wireless")
            icon.name: "network-wireless-connected-100"
            onTriggered: plasmoid.nativeInterface.executeCommand("plasma-settings -s -m kcm_mediacenter_wifi")
            property bool active: true
        },
        Controls.Action {
            text: i18n("KDE Connect")
            icon.name: "kdeconnect"
            onTriggered: plasmoid.nativeInterface.executeCommand("plasma-settings -s -m kcm_mediacenter_kdeconnect")
            property bool active: true
        }
    ]

    property list<Controls.Action> actionWithIntegration: [
        Controls.Action {
            text: i18n("Audio")
            icon.name: "audio-volume-high"
            onTriggered: plasmoid.nativeInterface.executeCommand("plasma-settings -s -m kcm_audiodevice")
            property bool active: true
        },
        Controls.Action {
            text: i18n("Bigscreen Settings")
            icon.name: "view-grid-symbolic"
            onTriggered: plasmoid.nativeInterface.executeCommand("plasma-settings -s -m kcm_mediacenter_bigscreen_settings")
            property bool active: true
        },
        Controls.Action {
            text: i18n("Wallpaper")
            icon.name: "preferences-desktop-wallpaper"
            onTriggered: plasmoid.action("configure").trigger();
            property bool active: true
        },
        Controls.Action {
            text: i18n("Wireless")
            icon.name: "network-wireless-connected-100"
            onTriggered: plasmoid.nativeInterface.executeCommand("plasma-settings -s -m kcm_mediacenter_wifi")
            property bool active: true
        },
        Controls.Action {
            text: i18n("KDE Connect")
            icon.name: "kdeconnect"
            onTriggered: plasmoid.nativeInterface.executeCommand("plasma-settings -s -m kcm_mediacenter_kdeconnect")
            property bool active: true
        },
        Controls.Action {
            text: i18n("Mycroft Skill Installer")
            icon.name: "download"
            onTriggered: plasmoid.nativeInterface.executeCommand("MycroftSkillInstaller")
            property bool active: mycroftIntegration
        }
    ]
}
