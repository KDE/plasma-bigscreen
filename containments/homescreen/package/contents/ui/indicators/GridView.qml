// SPDX-FileCopyrightText: 2026 Wolf Luyten <wolfluyten@mailfence.com>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import org.kde.plasma.plasmoid
import "../launcher"

AbstractIndicator {
    id: gridViewIcon

    property int currentLauncherView

    icon.name: currentLauncherView == LauncherMenu.CurrentView.Home ? "view-app-grid-symbolic" : "application-menu-symbolic"
    text: currentLauncherView == LauncherMenu.CurrentView.Home ? i18n("Show app grid") : i18n("Hide app grid")

    onClicked: {
        Plasmoid.toggleLauncherGrid()
    }
}
