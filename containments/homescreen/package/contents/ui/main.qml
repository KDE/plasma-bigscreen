// SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
// SPDX-FileCopyrightText: 2019 Aditya Mehra <aix.m@outlook.com>
// SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import QtQuick.Window

import org.kde.bigscreen as Bigscreen
import org.kde.kirigami as Kirigami
import org.kde.bigscreen.controllerhandler as ControllerHandler
import org.kde.bigscreen.shell as BigscreenShell
import org.kde.kquickcontrolsaddons
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import org.kde.private.biglauncher
import org.kde.taskmanager as TaskManager

import "consolescreen"
import "homeoverlay"
import "homescreen"
import "navbar" as Navbar
import "search" as Search

ContainmentItem {
    

    id: root

    Layout.minimumWidth: Screen.desktopAvailableWidth
    Layout.minimumHeight: Screen.desktopAvailableHeight * 0.6

    function activateHome() {
        if (homeOverlayWindow.visible)
            homeOverlayWindow.hideOverlay();
        else
            homeOverlayWindow.showOverlay();
    }

    // Action for when Meta key is pressed
    Plasmoid.onActivated: {
        root.activateHome();
    }

    // Trigger home overlay for back action
    Bigscreen.BackHandler.onActivated: {
        homeOverlayWindow.showOverlay();
    }


    Component.onCompleted: {
        //add welcome things
    }

    Connections {
        function onToggleHomeScreen() {
            if (homeOverlayWindow.visible)
                homeOverlayWindow.hideOverlay();

            tasksModel.minimizeAllTasks();
        }

        target: Shortcuts
    }

    Connections {
        function onOpenTasksRequested() {
            homeOverlayWindow.showOverlay();
            homeOverlayWindow.openTasks();
        }

        function onOpenSearchRequested() {
            searchWindow.showOverlay();
        }

        function onOpenHomeOverlayRequested() {
            homeOverlayWindow.showOverlay();
        }

        function onMinimizeAllTasksRequested() {
            tasksModel.minimizeAllTasks();
        }

        target: Plasmoid
    }

    Connections {
        function onHomeActionRequested() {
            root.activateHome();
        }

        function onSdlControllerAdded(name) {
            Plasmoid.showOSD(i18n("Controller added: %1", name), "input-gamepad-symbolic");
        }

        function onSdlControllerRemoved(name) {
            Plasmoid.showOSD(i18n("Controller removed: %1", name), "input-gamepad-symbolic");
        }

        function onCecControllerAdded(name) {
            Plasmoid.showOSD(i18n("Remote added: %1", name), "input-tvremote-symbolic");
        }

        function onCecControllerRemoved(name) {
            Plasmoid.showOSD(i18n("Remote removed: %1", name), "input-tvremote-symbolic");
        }

        function onInputSuppressedChanged(suppressed, automatic) {
            const systemTakingOver = i18n("System taking over controller input");
            if (automatic) {
                if (suppressed)
                    Plasmoid.showOSD(i18n("Application taking over controller input"), "input-gamepad-symbolic");
                else
                    Plasmoid.showOSD(systemTakingOver, "input-gamepad-symbolic");
            }
        }

        target: ControllerHandler.ControllerHandlerStatus
    }

    PowerManagementItem {
        id: pmInhibitItem

        inhibit: BigscreenShell.Settings.pmInhibitionEnabled
    }

    TaskManager.TasksModel {
        id: tasksModel

        function minimizeAllTasks() {
            for (var i = 0; i < tasksModel.count; i++) {
                const idx = tasksModel.makeModelIndex(i);
                tasksModel.requestToggleMinimized(idx);
            }
        }

        filterByVirtualDesktop: false
        filterByActivity: false
        filterNotMaximized: false
        filterByScreen: false
        filterHidden: true
        groupMode: TaskManager.TasksModel.GroupDisabled
    }

    Search.SearchWindow {
        id: searchWindow
    }

    HomeOverlayWindow {
        id: homeOverlayWindow

        onMinimizeAllTasksRequested: tasksModel.minimizeAllTasks()
        onSearchRequested: Plasmoid.openSearch()
        onSettingsRequested: Plasmoid.openSettings()
    }

    // Background darken scrim
    Rectangle {
        anchors.fill: parent
        color: 'black'
        opacity: homeScreen.darkenBackground ? 0.7 : 0.4

        Behavior on opacity {
            NumberAnimation {
                duration: Kirigami.Units.longDuration
            }

        }

    }

    // Shared Top Navigation Bar
    Navbar.Navbar {
        id: mainNavbar
        downFocusItem: screenStack.children[screenStack.currentIndex]
        state: (mainNavbar.activeTabIndex === 0 && !homeScreen.scrolledDown) ? "large" : "shrunk"
        z: 99
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            leftMargin: Kirigami.Units.gridUnit * 2
            rightMargin: Kirigami.Units.gridUnit * 2
        }
    }

    // The Screen Switcher
    StackLayout {
        id: screenStack

        anchors.fill: parent
        currentIndex:  1//mainNavbar.activeTabIndex

        // INDEX 0: HOME SCREEN
        HomeScreen {
            id: homeScreen

            header: mainNavbar
            KeyNavigation.up: mainNavbar.focusTarget
            focus: true
        }

        // INDEX 1: GAMES SCREEN
        ConsoleScreen {
            id: consoleScreen

            header: mainNavbar
            KeyNavigation.up: mainNavbar.focusTarget
            focus: true
        }

    }

}
