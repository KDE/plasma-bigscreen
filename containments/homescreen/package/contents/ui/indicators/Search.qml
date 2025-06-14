// SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls as Controls

import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami
import org.kde.kdeconnect as KDEConnect
import org.kde.plasma.private.nanoshell as NanoShell
import org.kde.private.biglauncher

import "../launcher/search" as Search

AbstractIndicator {
    id: settingsIcon
    icon.name: "search"

    onClicked: {
        searchWindow.showOverlay();
    }

    Search.SearchWindow {
        id: searchWindow
    }
}