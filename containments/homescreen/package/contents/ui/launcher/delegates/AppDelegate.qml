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

Bigscreen.IconDelegate {
    id: delegate
    readonly property var appStorageIdRole: modelData.ApplicationStorageIdRole

    icon.name: modelData ? modelData.ApplicationIconRole : ""
    text: modelData ? modelData.ApplicationNameRole : ""
    useIconColors: plasmoid.configuration.coloredTiles

    onClicked: {
        Bigscreen.NavigationSoundEffects.playClickedSound()
        feedbackWindow.open(delegate.text,
                            delegate.icon.name.length > 0 ? delegate.icon.name : model.decoration);
        Plasmoid.applicationListModel.runApplication(modelData.ApplicationStorageIdRole)
    }
}
