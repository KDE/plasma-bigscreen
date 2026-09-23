/*
    SPDX-FileCopyrightText: 2019 Aditya Mehra <aix.m@outlook.com>
    SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.bigscreen as Bigscreen
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid

IconDelegate {
    id: delegate
    useIconColors: Plasmoid.configuration.coloredTiles

    icon.name: parent.modelData.ApplicationIconRole
    text: parent.modelData ? parent.modelData.ApplicationNameRole : ""

    onClicked: {
        Bigscreen.NavigationSoundEffects.playClickedSound();
        Bigscreen.NavigationRumble.playConfirmRumble();
        if (Plasmoid.applicationListModel.isApplicationRunning(parent.modelData.ApplicationStorageIdRole)) {
            Plasmoid.applicationListModel.maximizeApplication(parent.modelData.ApplicationStorageIdRole);
        } else {
            Plasmoid.showAppLaunchScreen(delegate.text, delegate.icon.name.length > 0 ? delegate.icon.name : model.decoration);
            Plasmoid.applicationListModel.runApplication(parent.modelData.ApplicationStorageIdRole);
        }
    }
}
