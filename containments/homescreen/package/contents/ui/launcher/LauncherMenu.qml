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
    readonly property bool scrolledDown:
        currentView == LauncherMenu.CurrentView.Home ? launcherHome.scrolledDown : true

    enum CurrentView {
        Home = 0,
        Grid = 1
    }
    property int currentView: LauncherMenu.CurrentView.Home;

    onActiveFocusChanged: {
        if (activeFocus) {
            if (currentView == LauncherMenu.CurrentView.Home){
                if (!launcherHome.activeFocus) launcherHome.activateAppView();
            } else {
                if (!launcherGridView.activeFocus) launcherGridView.forceActiveFocus();
            }
        }
    }

    Connections {
        target: Plasmoid

        function onToggleLauncherGridRequested() {
            if (currentView == LauncherMenu.CurrentView.Home){
                currentView = LauncherMenu.CurrentView.Grid
                launcherGridView.visible = true
            } else{
                currentView = LauncherMenu.CurrentView.Home
                launcherHome.visible = true
            }
        }
    }

    Controls.Label {
        id: metrics
        text: "M\nM"
        visible: false
    }

    LauncherHome {
        id: launcherHome
        opacity: currentView == LauncherMenu.CurrentView.Home ? 1 : 0
        anchors {
            fill: parent
            leftMargin: root.leftMargin
            rightMargin: root.rightMargin
        }
        navigationUp: root.KeyNavigation.up
        startY: root.startY

        Behavior on opacity {
            OpacityAnimator {
                // Set shorter animation speed to disappear
                duration: currentView == LauncherMenu.CurrentView.Home ? 300 : 500
                easing.type: Easing.OutCubic
                onFinished: {
                    if (currentView == LauncherMenu.CurrentView.Grid)
                        launcherHome.visible = false;
                }
            }
        }
    }

    LauncherGridView {
        id: launcherGridView
        opacity: currentView == LauncherMenu.CurrentView.Grid ? 1 : 0
        anchors {
            fill: parent
            leftMargin: root.leftMargin
            rightMargin: root.rightMargin
            topMargin: currentView == LauncherMenu.CurrentView.Grid ? 0 : height/4
        }

        Behavior on opacity {
            OpacityAnimator {
                // Set shorter animation speed to disappear
                duration: currentView == LauncherMenu.CurrentView.Grid ? 300 : 500
                easing.type: Easing.OutCubic
            }
        }

        Behavior on anchors.topMargin {
            NumberAnimation {
                duration: 500
                easing.type: Easing.OutCubic
                onFinished: {
                    if (currentView == LauncherMenu.CurrentView.Home)
                        launcherGridView.visible = false;
                }
            }
        }
    }
}
