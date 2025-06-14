/*
    SPDX-FileCopyrightText: 2019 Aditya Mehra <aix.m@outlook.com>
    SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import QtQuick.Window

import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kquickcontrolsaddons
import org.kde.bigscreen as Launcher
import org.kde.private.biglauncher
import org.kde.kirigami as Kirigami

FocusScope {
    id: root

    property real leftMargin
    property real rightMargin

    readonly property int reservedSpaceForLabel: metrics.height

    // Whether the view has scrolled down at least one row
    readonly property bool scrolledDown: launcherHome.scrolledDown

    signal activateAppView
    signal activateTopNavBar
    signal activateSettingsView

    property Item wallpaper: {
        for (var i in plasmoid.children) {
            if (plasmoid.children[i].toString().indexOf("WallpaperInterface") === 0) {
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
        target: plasmoid.applicationListModel
        function onAppOrderChanged() {
            root.activateAppView()
        }
    }

    Connections {
        target: plasmoid.bigLauncherDbusAdapterInterface
        function onUseColoredTilesChanged(msgUseColoredTiles) {
            plasmoid.configuration.coloredTiles = msgUseColoredTiles;
            plasmoid.setUseColoredTiles(plasmoid.configuration.coloredTiles);
        }
        function onUseExpandableTilesChanged(msgUseExpandableTiles) {
            plasmoid.configuration.expandingTiles = msgUseExpandableTiles;
            plasmoid.setUseExpandableTiles(plasmoid.configuration.expandingTiles);
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

    LauncherHome {
        id: launcherHome
        anchors {
            fill: parent
            leftMargin: root.leftMargin
            rightMargin: root.rightMargin
        }

        navigationUp: root.KeyNavigation.up
    }
}