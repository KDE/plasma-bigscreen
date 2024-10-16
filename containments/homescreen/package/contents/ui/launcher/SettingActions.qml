/*
    SPDX-FileCopyrightText: 2019 Aditya Mehra <aix.m@outlook.com>
    SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Controls as Controls
import org.kde.plasma.plasmoid

Item {
    id: settingActions

    function launchSettings(kcm_id) {
        if (kcm_id.indexOf("kcm_mediacenter_wallpaper") != -1) {
            plasmoid.internalAction("configure").trigger();
        } else {
            configWindow.showOverlay(kcm_id)
        }
    }
}
