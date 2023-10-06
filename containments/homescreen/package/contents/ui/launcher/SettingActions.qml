/*
    SPDX-FileCopyrightText: 2019 Aditya Mehra <aix.m@outlook.com>
    SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import org.kde.plasma.plasmoid 2.0
import QtQuick 2.14
import QtQuick.Controls 2.14 as Controls

Item {
    id: settingActions

    function launchSettings(kcm_id) {
        if (kcm_id.indexOf("kcm_mediacenter_wallpaper") != -1) {
            Plasmoid.action("configure").trigger();
        } else if (kcm_id.indexOf("kcm_mediacenter_mycroft_skill_installer") != -1) {
            Plasmoid.nativeInterface.executeCommand("MycroftSkillInstaller")
        } else {
            Plasmoid.nativeInterface.executeCommand("plasma-settings -s -m " + kcm_id)
        }
    }
}
