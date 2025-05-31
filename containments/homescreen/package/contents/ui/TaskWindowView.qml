/*
    SPDX-FileCopyrightText: 2019 Aditya Mehra <aix.m@outlook.com>
    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Window
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami
import org.kde.bigscreen as Bigscreen
import org.kde.private.biglauncher 
import org.kde.plasma.private.nanoshell as NanoShell
import org.kde.taskmanager as TaskManager
import org.kde.plasma.core as PlasmaCore
import org.kde.kitemmodels as KItemModels
import "launcher/delegates" as Delegates

NanoShell.FullScreenOverlay {
    id: taskOverlay
    width: Screen.desktopAvailableWidth
    height: Screen.desktopAvailableHeight
    visible: false
    color: "transparent"
    property int modelCount: tasksModel.count

    function showOverlay() {
        if (!taskOverlay.visible) {
            taskOverlay.visible = true;
            taskListView.forceActiveFocus();
        }
        tasksModel.syncLaunchers();
    }

    function hideOverlay() {
        if (taskOverlay.visible) {
            taskOverlay.visible = false;
        }
    }

    function closeAllTasks() {
        for (var i = 0; i < tasksModel.count; i++) {
            tasksModel.requestClose(tasksModel.makeModelIndex(i));
        }
    }

    function minimizeAllTasks() {
        for (var i = 0; i < tasksModel.count; i++) {
            const idx = tasksModel.makeModelIndex(i);
            if (!tasksModel.data(idx, TaskManager.AbstractTasksModel.IsHidden)) {
                tasksModel.requestToggleMinimized(idx);
            }
        }
    }
    
    TaskManager.TasksModel {
        id: tasksModel
        filterByVirtualDesktop: false
        filterByActivity: false
        filterNotMaximized: false
        filterByScreen: false
        filterHidden: false        
        groupMode: TaskManager.TasksModel.GroupDisabled
    }

    Rectangle {
        id: windowBackgroundDimmer
        anchors.fill: parent
        color: Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 0.5)
        visible: taskOverlay.visible
    }

    Controls.Control {
        id: tasksContainerHolder
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.right: parent.right
        height: Kirigami.Units.gridUnit * 18
        opacity: taskOverlay.visible ? 1 : 0

        background: Kirigami.ShadowedRectangle {
            color: Kirigami.Theme.backgroundColor
            shadow {
                size: Kirigami.Units.largeSpacing * 1
            }
        }

        Item {
            id: tasksContainer
            anchors.fill: parent
            anchors.margins: Kirigami.Units.largeSpacing

            ListView {
                id: taskListView
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.topMargin: Kirigami.Units.gridUnit
                anchors.bottomMargin: Kirigami.Units.gridUnit
                anchors.rightMargin: Kirigami.Units.gridUnit
                anchors.leftMargin: Kirigami.Units.gridUnit * 2.5
                orientation: ListView.Horizontal
                model: tasksModel
                keyNavigationEnabled: true
                highlightRangeMode: ListView.StrictlyEnforceRange
                snapMode: ListView.SnapToItem
                readonly property int cellWidth: parent.width / 5.5
                readonly property int cellHeight: parent.height

                Keys.onEscapePressed: hideOverlay()
                Keys.onDownPressed: closeAllTasksButton.forceActiveFocus()

                onCurrentItemChanged: {
                    positionViewAtIndex(taskListView.currentIndex, ListView.Contain)
                }

                delegate: Bigscreen.TaskDelegate {
                    id: taskDelegate
                    iconImage: model.decoration
                    text: model.AppName
                    onClicked: {
                        tasksModel.requestActivate(tasksModel.makeModelIndex(index))
                        taskOverlay.hideOverlay()
                    }
                    onPressAndHold: {
                        tasksModel.requestClose(tasksModel.makeModelIndex(index))
                    }
                }

                move: Transition {
                    NumberAnimation { properties: "x,y"; duration: 200 }
                }

                moveDisplaced: Transition {
                    NumberAnimation { properties: "x,y"; duration: 200 }
                }            
            }
        }
    }

    RowLayout {
        anchors.top: tasksContainerHolder.bottom
        anchors.topMargin: Kirigami.Units.gridUnit
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: Kirigami.Units.gridUnit * 2
        anchors.rightMargin: Kirigami.Units.gridUnit * 2
        height: Kirigami.Units.gridUnit * 4
        spacing: Kirigami.Units.gridUnit

        Controls.Button {
            id: closeAllTasksButton
            Layout.fillHeight: true
            Layout.fillWidth: true
            KeyNavigation.up: taskListView
            KeyNavigation.right: closeButton
            KeyNavigation.down: favAppsView

            background: Kirigami.ShadowedRectangle {
                color: closeAllTasksButton.activeFocus ? Kirigami.Theme.highlightColor : Kirigami.Theme.backgroundColor
                radius: 6
                shadow {
                    size: Kirigami.Units.largeSpacing * 1
                }
            }

            contentItem: Item {
                RowLayout {
                    anchors.centerIn: parent
                    Kirigami.Icon {
                        Layout.fillHeight: true
                        Layout.preferredWidth: height                  
                        source: "edit-clear-all"
                    }
                    Controls.Label {
                        fontSizeMode: Text.Fit
                        minimumPixelSize: 8
                        font.pixelSize: 18
                        text: i18n("Clear Tasks")
                    }
                }
            }

            onClicked: closeAllTasks()
            Keys.onReturnPressed: closeAllTasks()
        }

        Controls.Button {
            id: closeButton
            Layout.fillHeight: true
            Layout.fillWidth: true
            KeyNavigation.up: taskListView
            KeyNavigation.left: closeAllTasksButton
            KeyNavigation.down: favAppsView

            background: Kirigami.ShadowedRectangle {
                color: closeButton.activeFocus ? Kirigami.Theme.highlightColor : Kirigami.Theme.backgroundColor
                radius: 6
                shadow {
                    size: Kirigami.Units.largeSpacing * 1
                }
            }

            contentItem: Item {
                RowLayout {
                    anchors.centerIn: parent
                    Kirigami.Icon {
                        Layout.fillHeight: true
                        Layout.preferredWidth: height                  
                        source: "window-close"
                    }
                    Controls.Label {
                        fontSizeMode: Text.Fit
                        minimumPixelSize: 8
                        font.pixelSize: 18
                        text: i18n("Close")
                    }
                }
            }

            onClicked: hideOverlay()
            Keys.onReturnPressed: hideOverlay()
        }
    }

    Bigscreen.TileRepeater {
        id: favAppsView
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: Kirigami.Units.largeSpacing
        titleVisible: false
        model: plasmoid.favsListModel
        visible: count > 0
        currentIndex: 0
        focus: false
        columns: 7
        delegate: Delegates.FavDelegate {
            property var modelData: typeof model !== "undefined" ? model : null

            onClicked: {
                hideOverlay()
                Bigscreen.NavigationSoundEffects.playClickedSound()
                NanoShell.StartupFeedback.open(
                                    delegate.icon.name.length > 0 ? delegate.icon.name : model.decoration,
                                    delegate.text,
                                    delegate.Kirigami.ScenePosition.x + delegate.width/2,
                                    delegate.Kirigami.ScenePosition.y + delegate.height/2,
                                    Math.min(delegate.width, delegate.height), delegate.Kirigami.Theme.backgroundColor);
                plasmoid.applicationListModel.runApplication(modelData.ApplicationStorageIdRole)
            }
        }

        navigationUp: closeButton
    }
}