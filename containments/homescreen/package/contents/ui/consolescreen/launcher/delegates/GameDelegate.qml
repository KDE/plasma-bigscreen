/*
    SPDX-FileCopyrightText: 2019 Aditya Mehra <aix.m@outlook.com>
    SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import org.kde.bigscreen as Bigscreen
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid

IconDelegate {
    id: delegate
    
    readonly property var gameData: typeof modelData !== "undefined" ? modelData : null
    
    property string launchCommand: typeof gameData !== "undefined" && gameData.command ? gameData.command : ""

    onClicked: {
        Bigscreen.NavigationSoundEffects.playClickedSound();
        
        // Show the launch splash screen 
        Plasmoid.showAppLaunchScreen(delegate.gameData.name, delegate.gameData.grid_path);
        
        // Execute your custom JSON command!
        if (launchCommand.startsWith("steam://")) {
            Qt.openUrlExternally(launchCommand);
        } else {
            Plasmoid.executeCommand(launchCommand);
        }
    }
}