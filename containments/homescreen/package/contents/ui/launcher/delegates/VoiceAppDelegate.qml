/*
    SPDX-FileCopyrightText: 2019 Aditya Mehra <aix.m@outlook.com>
    SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.14
import org.kde.mycroft.bigscreen 1.0 as BigScreen

BigScreen.IconDelegate {
    readonly property var vAppStorageIdRole: modelData.ApplicationStorageIdRole

    icon.name: modelData && modelData.ApplicationIconRole ? modelData.ApplicationIconRole : ""
    text: modelData ? modelData.ApplicationNameRole : ""
    useIconColors: plasmoid.configuration.coloredTiles
    compactMode: plasmoid.configuration.expandingTiles

    onClicked: {
        BigScreen.NavigationSoundEffects.playClickedSound()
        plasmoid.nativeInterface.applicationListModel.runApplication(modelData.ApplicationStorageIdRole)
        recentView.forceActiveFocus();
        recentView.currentIndex = 0;
    }
}
