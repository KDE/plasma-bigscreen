/*
 * Copyright 2019 Aditya Mehra <aix.m@outlook.com>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  2.010-1301, USA.
 */

import QtQuick 2.14
import org.kde.mycroft.bigscreen 1.0 as BigScreen
import org.kde.kirigami 2.12 as Kirigami
import org.kde.plasma.private.nanoshell 2.0 as NanoShell

BigScreen.IconDelegate {
    id: delegate
    icon.name: model.icon.name
    text: model.text
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
        trigger();
        recentView.forceActivefocus();
        recentView.currentIndex = 0;
    }
}
