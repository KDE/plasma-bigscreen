// SPDX-FileCopyrightText: 2026 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Window
import QtQuick.Controls as QQC2

import org.kde.kirigami as Kirigami
import org.kde.plasma.private.nanoshell as NanoShell
import org.kde.plasma.plasma5support as P5Support
import org.kde.private.biglauncher
import org.kde.bigscreen as Bigscreen
import org.kde.bigscreen.controllerhandler as ControllerHandler
import org.kde.layershell as LayerShell

Window {
    id: window

    LayerShell.Window.scope: "overlay"
    LayerShell.Window.anchors: LayerShell.Window.AnchorTop | LayerShell.Window.AnchorLeft | LayerShell.Window.AnchorRight | LayerShell.Window.AnchorBottom
    LayerShell.Window.layer: LayerShell.Window.LayerOverlay
    LayerShell.Window.exclusionZone: -1

    signal minimizeAllTasksRequested()
    signal searchRequested()
    signal settingsRequested()

    Kirigami.Theme.inherit: false
    Kirigami.Theme.colorSet: Kirigami.Theme.View
    color: Qt.rgba(0, 0, 0, 0.3 * sidebar.openFactor)

    function openTasks() {
        tasksView.open();
    }

    function showOverlay() {
        showMaximized();
    }

    function hideOverlay() {
        tasksView.visible = false;
        sidebar.close();
    }

    onVisibleChanged: {
        if (visible) {
            sidebar.open()
        } else {
            tasksView.visible = false;
        }
    }
    onActiveChanged: {
        if (!active) {
            sidebar.close();
        }
    }

    Connections {
        target: Shortcuts

        function onToggleHomeOverlay() {
            if (window.visible) {
                sidebar.close();
            } else {
                window.showFullScreen();
            }
        }
    }

    // Fallback in case the sidebar somehow gets stuck
    MouseArea {
        anchors.fill: parent
        onClicked: window.close()
    }

    HomeOverlaySidebar {
        id: sidebar

        onAboutToHide: tasksView.close()
        onClosed: window.close();

        contentItem: MainColumn {
            id: mainColumn
            showTasksButton: tasksView.taskCount > 0
            implicitWidth: sidebar.columnWidth
            Layout.fillHeight: true

            Keys.onRightPressed: {
                if (tasksView.visible) {
                    tasksView.forceActiveFocus();
                }
            }

            onMinimizeAllTasksRequested: {
                window.minimizeAllTasksRequested();
                window.hideOverlay();
            }
            onSearchRequested: {
                window.searchRequested();
                window.hideOverlay();
            }
            onTasksRequested: {
                tasksView.open();
                tasksView.forceActiveFocus();
            }
            onSettingsRequested: {
                window.settingsRequested();
                window.hideOverlay();
            }
        }
    }

    TasksView {
        id: tasksView

        visible: false
        leftMargin: sidebar.width * sidebar.openFactor
        anchors.fill: parent

        onFocusTasksRequested: {
            mainColumn.focusTasks();
        }

        onVisibleChanged: {
            if (!visible) {
                mainColumn.focusTasks();
            }
        }

        onCloseHomeRequested: window.hideOverlay();
    }
}
