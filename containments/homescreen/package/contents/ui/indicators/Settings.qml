/*
    SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2019 Aditya Mehra <aix.m@outlook.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.14
import QtQuick.Window 2.14
import QtQuick.Layouts 1.14
import QtQml.Models 2.14
import org.kde.plasma.plasmoid 2.0
import QtQuick.Controls 2.14 as Controls
import org.kde.kirigami 2.12 as Kirigami
import org.kde.kdeconnect 1.0 as KDEConnect
import org.kde.plasma.private.nanoshell as NanoShell

AbstractIndicator {
    id: settingsIcon
    icon.name: "configure"

    onClicked: {
     configWindow.showOverlay()   
    }
}