/*
    SPDX-FileCopyrightText: 2019 Aditya Mehra <aix.m@outlook.com>
    SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import org.kde.plasma.plasmoid 2.0
import QtQuick 2.14
import QtQuick.Layouts 1.14
import QtQuick.Controls 2.14 as Controls
import QtQuick.Window 2.14

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.kquickcontrolsaddons 2.0
import org.kde.mycroft.bigscreen 1.0 as Launcher
import org.kde.private.biglauncher 1.0
import org.kde.kirigami 2.12 as Kirigami

FocusScope {
    id: root

    readonly property int reservedSpaceForLabel: metrics.height
    signal activateAppView
    signal activateTopNavBar
    signal activateSettingsView

    property Item wallpaper: {
        for (var i in Plasmoid.children) {
            if (Plasmoid.children[i].toString().indexOf("WallpaperInterface") === 0) {
                return Plasmoid.children[i];
            }
        }
        return null;
    }

    Component.onCompleted: {
        root.forceActiveFocus();
        Plasmoid.nativeInterface.kcmsListModel.loadKcms();
        Plasmoid.nativeInterface.applicationListModel.loadApplications();
        root.activateAppView();
        Plasmoid.nativeInterface.setUseColoredTiles(Plasmoid.configuration.coloredTiles);
        Plasmoid.nativeInterface.setUseExpandableTiles(Plasmoid.configuration.expandingTiles);
    }

    Connections {
        target: Plasmoid.applicationListModel
        onAppOrderChanged: {
            root.activateAppView()
        }
    }

    Connections {
        target: Plasmoid.nativeInterface.bigLauncherDbusAdapterInterface
        onUseColoredTilesChanged: {
            Plasmoid.configuration.coloredTiles = msgUseColoredTiles;
            Plasmoid.nativeInterface.setUseColoredTiles(Plasmoid.configuration.coloredTiles);
        }
        onUseExpandableTilesChanged: {
            Plasmoid.configuration.expandingTiles = msgUseExpandableTiles;
            Plasmoid.nativeInterface.setUseExpandableTiles(Plasmoid.configuration.expandingTiles);
        }
    }

    Connections {
        target: root
        onActivateTopNavBar: {
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
