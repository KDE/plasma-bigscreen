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
import "homeoverlay"
import "search" as Search

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
        tasksModel.minimizeAllTasks();
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

        function onUseWallpaperBlurChanged(msgUseWallpaperBlur) {
            Plasmoid.configuration.wallpaperBlur = msgUseWallpaperBlur;
            Plasmoid.setUseWallpaperBlur(Plasmoid.configuration.wallpaperBlur);
        }

        function onActivateWallpaperSelectorRequested() {
            root.configureWallpaper();
        }
    }

    Connections {
        target: Shortcuts

        function onToggleHomeScreen() {
            tasksModel.minimizeAllTasks();
        }
    }

    Connections {
        target: Plasmoid

        function onOpenTasksRequested() {
            taskWindowView.showOverlay();
        }

        function onOpenSearchRequested() {
            searchWindow.showOverlay();
        }

        function onOpenHomeOverlayRequested() {
            homeOverlayWindow.showOverlay();
        }
    }

    // Trigger home overlay for back and left action
    Keys.onEscapePressed: {
        homeOverlayWindow.showOverlay();
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
        Plasmoid.setUseWallpaperBlur(Plasmoid.configuration.wallpaperBlur)
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

        function minimizeAllTasks() {
            for (var i = 0; i < tasksModel.count; i++) {
                const idx = tasksModel.makeModelIndex(i);
                tasksModel.requestToggleMinimized(idx);
            }
        }
    }

    // Shell windows
    StartupFeedbackWindow {
        id: feedbackWindow
    }

    Search.SearchWindow {
        id: searchWindow
    }

    TaskWindowView {
        id: taskWindowView
    }

    FavoritesManager {
        id: favsManagerWindowView
    }

    HomeOverlayWindow {
        id: homeOverlayWindow

        showTasksButton: taskWindowView.modelCount > 1 // TODO: HACK: the home overlay window counts as a task
        onMinimizeAllTasksRequested: tasksModel.minimizeAllTasks()
        onSearchRequested: Plasmoid.openSearch()
        onTasksRequested: Plasmoid.openTasks()
        onSettingsRequested: Plasmoid.openSettings()
    }

    // Homescreen background - only loaded when wallpaperBlur setting is enabled
    Loader {
        id: wallpaperBlurLoader
        anchors.fill: parent
        active: Plasmoid.configuration.wallpaperBlur
        sourceComponent: Item {
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
