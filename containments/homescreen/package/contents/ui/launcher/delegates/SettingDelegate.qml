/*
    SPDX-FileCopyrightText: 2019 Aditya Mehra <aix.m@outlook.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import org.kde.bigscreen as Bigscreen
import org.kde.kirigami as Kirigami

Bigscreen.IconDelegate {
    id: delegate
    icon.name: modelData.kcmIconName
    text: modelData.kcmName
    useIconColors: plasmoid.configuration.coloredTiles
    compactMode: plasmoid.configuration.expandingTiles

    onClicked: {
        Bigscreen.NavigationSoundEffects.playClickedSound()
        settingActions.launchSettings(modelData.kcmId)
        recentView.forceActiveFocus();
        recentView.currentIndex = 0;
    }
}
