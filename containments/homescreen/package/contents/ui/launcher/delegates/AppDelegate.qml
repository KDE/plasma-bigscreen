/*
    SPDX-FileCopyrightText: 2019 Aditya Mehra <aix.m@outlook.com>
    SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import org.kde.bigscreen as Bigscreen
import org.kde.kirigami as Kirigami
import org.kde.plasma.private.nanoshell as NanoShell
import org.kde.plasma.plasmoid

IconDelegate {
    id: delegate
    property string applicationStorageId: modelData ? modelData.ApplicationStorageIdRole : ""
    property var launchApplication: function() {
        Plasmoid.applicationListModel.runApplication(delegate.applicationStorageId);
    }

    icon.name: modelData ? modelData.ApplicationIconRole : ""
    text: modelData ? modelData.ApplicationNameRole : ""
    useIconColors: Plasmoid.configuration.coloredTiles

    onClicked: {
        Bigscreen.NavigationSoundEffects.playClickedSound();
        if (Plasmoid.applicationListModel.isApplicationRunning(delegate.applicationStorageId)) {
            Plasmoid.applicationListModel.maximizeApplication(delegate.applicationStorageId);
        } else {
            Plasmoid.showAppLaunchScreen(delegate.text, delegate.icon.name.length > 0 ? delegate.icon.name : model.decoration);
            delegate.launchApplication();
        }
    }
}
