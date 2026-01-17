// SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
// SPDX-FileCopyrightText: 2019 Aditya Mehra <aix.m@outlook.com>
// SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import QtQuick.Window
import Qt5Compat.GraphicalEffects
import org.kde.taskmanager as TaskManager

import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kquickcontrolsaddons
import org.kde.private.biglauncher

import "launcher"

ContainmentItem {
    id: root
    Layout.minimumWidth: Screen.desktopAvailableWidth
    Layout.minimumHeight: Screen.desktopAvailableHeight * 0.6

    property Item wallpaper

    function configureWallpaper() {
        Plasmoid.internalAction("configure").trigger();
    }

    Plasmoid.onActivated: {
        // Action when the meta key is pressed
        for (var i = 0; i < tasksModel.count; i++) {
            const idx = tasksModel.makeModelIndex(i);
            tasksModel.requestToggleMinimized(idx);
        }
    }

    Connections {
        target: BigLauncherDbusAdapterInterface

        function onEnablePmInhibitionChanged(pmInhibition) {
            var powerInhibition = BigLauncherDbusAdapterInterface.pmInhibitionActive()
            if (powerInhibition) {
                pmInhibitItem.inhibit = true
            } else {
                pmInhibitItem.inhibit = false
            }
        }

        function onUseColoredTilesChanged(msgUseColoredTiles) {
            Plasmoid.configuration.coloredTiles = msgUseColoredTiles;
            Plasmoid.setUseColoredTiles(Plasmoid.configuration.coloredTiles);
        }

        function onActivateWallpaperSelectorRequested() {
            root.configureWallpaper();
        }
    }

    Containment.onAppletAdded: (applet, x, y) => {
        addApplet(applet, x, y);
    }

    PowerManagementItem {
        id: pmInhibitItem
    }

    Component.onCompleted: {
        for (var i in Plasmoid.applets) {
            root.addApplet(Plasmoid.applets[i], -1, -1)
        }
        pmInhibitItem.inhibit = BigLauncherDbusAdapterInterface.pmInhibitionActive()
    }

    function addApplet(applet, x, y) {
        var container = appletContainerComponent.createObject(appletsLayout)
        print("Applet added: " + applet + " " + applet.title)

        const appletItem = root.itemFor(applet);
        appletItem.parent = container;
        container.applet = appletItem;
        appletItem.anchors.fill = container;
        appletItem.visible = true;
        appletItem.expanded = false;
    }

    Component {
        id: appletContainerComponent
        Item {
            property Item applet
            visible: applet && applet.status !== PlasmaCore.Types.HiddenStatus && applet.status !== PlasmaCore.Types.PassiveStatus
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        }
    }

    TaskManager.TasksModel {
        id: tasksModel
        filterByVirtualDesktop: false
        filterByActivity: false
        filterNotMaximized: false
        filterByScreen: false
        filterHidden: true
        groupMode: TaskManager.TasksModel.GroupDisabled
    }

    StartupFeedbackWindow {
        id: feedbackWindow
    }

    FavoritesManager {
        id: favsManagerWindowView
    }

    // Homescreen background
    Item {
        id: wallpaperBlur
        anchors.fill: parent

        // Only take samples from wallpaper when we need the blur for performance
        ShaderEffectSource {
            id: controlledWallpaperSource
            anchors.fill: parent

            sourceItem: Plasmoid.wallpaperGraphicsObject
            live: blur.visible
            hideSource: false
            visible: false
        }

        // Wallpaper blur
        // We attempted to use MultiEffect in the past, but it had very poor performance
        FastBlur {
            id: blur
            radius: 50
            cached: true
            source: controlledWallpaperSource
            anchors.fill: parent
            visible: true // Don't load and unload, which is laggy
            opacity: homeScreen.blurBackground ? 1 : 0

            Behavior on opacity { NumberAnimation { duration: 500 } }
        }
    }

    // Background darken scrim
    Rectangle {
        anchors.fill: parent
        color: 'black'
        opacity: homeScreen.darkenBackground ? 0.7 : 0.4
        Behavior on opacity { NumberAnimation { duration: 500 } }
    }

    // The homescreen's contents
    HomeScreen {
        id: homeScreen
        anchors.fill: parent
    }
}
