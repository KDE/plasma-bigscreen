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

Bigscreen.IconDelegate {
    id: delegate
    readonly property var appStorageIdRole: modelData.ApplicationStorageIdRole
    useIconColors: Plasmoid.configuration.coloredTiles

    icon.name: modelData.ApplicationIconRole
    text: modelData ? modelData.ApplicationNameRole : ""

    onClicked: {
        Bigscreen.NavigationSoundEffects.playClickedSound()
        Plasmoid.showAppLaunchScreen(delegate.text, delegate.icon.name.length > 0 ? delegate.icon.name : model.decoration);
        Plasmoid.applicationListModel.runApplication(modelData.ApplicationStorageIdRole)
    }
}
