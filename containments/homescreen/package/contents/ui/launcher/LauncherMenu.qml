/*
    SPDX-FileCopyrightText: 2019 Aditya Mehra <aix.m@outlook.com>
    SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15 as Controls
import QtQuick.Window 2.15

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.kquickcontrolsaddons 2.0
import org.kde.mycroft.bigscreen 1.0 as Launcher
import org.kde.private.biglauncher 1.0
import org.kde.kirigami 2.19 as Kirigami

FocusScope {
    id: root

    readonly property int reservedSpaceForLabel: metrics.height
    signal activateAppView
    signal activateTopNavBar
    signal activateSettingsView

    property Item wallpaper: {
        for (var i in Plasmoid.children) {
            if (Plasmoid.children[i].toString().indexOf("WallpaperInterface") === 0) {
                return plasmoid.children[i];
            }
        }
        return null;
    }

    Component.onCompleted: {
        root.forceActiveFocus();
        plasmoid.kcmsListModel.loadKcms();
        plasmoid.applicationListModel.loadApplications();
        root.activateAppView();
        plasmoid.setUseColoredTiles(plasmoid.configuration.coloredTiles);
        plasmoid.setUseExpandableTiles(plasmoid.configuration.expandingTiles);
    }

    Connections {
        target: Plasmoid.applicationListModel
        function onAppOrderChanged() {
            root.activateAppView()
        }
    }

    Connections {
        target: Plasmoid.bigLauncherDbusAdapterInterface
        function onUseColoredTilesChanged(msgUseColoredTiles) {
            Plasmoid.configuration.coloredTiles = msgUseColoredTiles;
            Plasmoid.setUseColoredTiles(plasmoid.configuration.coloredTiles);
        }
        function onUseExpandableTilesChanged(msgUseExpandableTiles) {
            Plasmoid.configuration.expandingTiles = msgUseExpandableTiles;
            Plasmoid.setUseExpandableTiles(plasmoid.configuration.expandingTiles);
        }
    }

    Connections {
        target: root
        function onActivateTopNavBar() {
            topButtonBar.focus = true
        }
    }

    Controls.Label {
        id: metrics
        text: "M\nM"
        visible: false
    }

    LauncherHome {}
}