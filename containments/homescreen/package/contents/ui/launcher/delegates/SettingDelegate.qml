/*
    SPDX-FileCopyrightText: 2019 Aditya Mehra <aix.m@outlook.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.14
import org.kde.mycroft.bigscreen 1.0 as BigScreen
import org.kde.kirigami 2.12 as Kirigami
import org.kde.plasma.private.nanoshell 2.0 as NanoShell

BigScreen.IconDelegate {
    id: delegate
    icon.name: modelData.kcmIconName
    text: modelData.kcmName
    useIconColors: plasmoid.configuration.coloredTiles
    compactMode: plasmoid.configuration.expandingTiles

    onClicked: {
        BigScreen.NavigationSoundEffects.playClickedSound()
        NanoShell.StartupFeedback.open(
                            delegate.icon.name,
                            delegate.text,
                            delegate.Kirigami.ScenePosition.x + delegate.width/2,
                            delegate.Kirigami.ScenePosition.y + delegate.height/2,
                            Math.min(delegate.width, delegate.height), delegate.Kirigami.Theme.backgroundColor);
        settingActions.launchSettings(modelData.kcmId)
        recentView.forceActiveFocus();
        recentView.currentIndex = 0;
    }
}
