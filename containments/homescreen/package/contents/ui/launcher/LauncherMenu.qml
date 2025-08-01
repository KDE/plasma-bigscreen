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

    property real startY
    property real leftMargin
    property real rightMargin

    readonly property int reservedSpaceForLabel: metrics.height

    // Whether the view has scrolled down at least one row
    readonly property bool scrolledDown: launcherHome.scrolledDown

    signal activateAppView
    signal activateTopNavBar

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
        plasmoid.applicationListModel.loadApplications();
        root.activateAppView();
        plasmoid.setUseColoredTiles(plasmoid.configuration.coloredTiles);
    }

    Connections {
        target: plasmoid.applicationListModel
        function onAppOrderChanged() {
            root.activateAppView()
        }
    }

    Connections {
        target: Plasmoid.bigLauncherDbusAdapterInterface

        function onUseColoredTilesChanged(msgUseColoredTiles) {
            Plasmoid.configuration.coloredTiles = msgUseColoredTiles;
            Plasmoid.setUseColoredTiles(Plasmoid.configuration.coloredTiles);
        }

        function onActivateWallpaperSelectorRequested() {
            Plasmoid.internalAction("configure").trigger();
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
        startY: root.startY
    }
}
