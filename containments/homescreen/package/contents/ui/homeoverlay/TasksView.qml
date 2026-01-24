// SPDX-FileCopyrightText: 2026 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2

import org.kde.kirigami as Kirigami
import org.kde.plasma.plasma5support as P5Support
import org.kde.private.biglauncher
import org.kde.bigscreen as Bigscreen
import org.kde.bigscreen.controllerhandler as ControllerHandler

import org.kde.taskmanager as TaskManager

Rectangle {
    id: root

    readonly property int taskCount: tasksModel.count

    property real leftMargin

    signal focusTasksRequested()
    signal closeHomeRequested()

    function open() {
        opacity = 0;
        visible = true;
        openAnim.restart();
    }
    function close() {
        closeAnim.restart();
    }

    Kirigami.Theme.inherit: false
    Kirigami.Theme.colorSet: Kirigami.Theme.View

    color: Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 0.8)

    NumberAnimation on opacity {
        id: closeAnim
        duration: Kirigami.Units.shortDuration
        to: 0
        onFinished: root.visible = false
    }

    NumberAnimation on opacity {
        id: openAnim
        duration: Kirigami.Units.shortDuration
        to: 1
    }

    Keys.onEscapePressed: close()

    onVisibleChanged: {
        if (visible) {
            gridView.forceActiveFocus();
        }
    }

    onFocusChanged: {
        if (focus) {
            gridView.forceActiveFocus();
        }
    }

    TaskManager.TasksModel {
        id: tasksModel
        filterByVirtualDesktop: true
        filterByActivity: true
        filterNotMaximized: false
        filterByScreen: true
        filterHidden: false
        groupMode: TaskManager.TasksModel.GroupDisabled

        onCountChanged: {
            if (count === 0) {
                if (root.visible) {
                    root.close();
                }
            }
        }

        function minimizeAllTasks() {
            for (var i = 0; i < tasksModel.count; i++) {
                const idx = tasksModel.makeModelIndex(i);
                tasksModel.requestToggleMinimized(idx);
            }
        }

        function closeAllTasks() {
            for (var i = 0; i < tasksModel.count; i++) {
                tasksModel.requestClose(tasksModel.makeModelIndex(i));
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: root.leftMargin

        spacing: 0

        QQC2.Label {
            Layout.margins: Kirigami.Units.gridUnit
            Layout.topMargin: Kirigami.Units.gridUnit * 2

            text: i18n("Open Apps")
            font.pixelSize: 32
            font.weight: Font.Light

            background: null
        }

        GridView {
            id: gridView
            model: tasksModel

            cellWidth: Math.min(Kirigami.Units.gridUnit * 16, width / 3)
            cellHeight: cellWidth * 0.5

            readonly property int columns: gridView.width / cellWidth

            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.leftMargin: Kirigami.Units.gridUnit
            Layout.rightMargin: Kirigami.Units.gridUnit

            Kirigami.Theme.inherit: false
            Kirigami.Theme.colorSet: Kirigami.Theme.Button

            KeyNavigation.down: closeAllButton

            delegate: TaskDelegate {
                tasksModel: gridView.model

                width: gridView.cellWidth
                height: gridView.cellHeight

                onCloseHomeRequested: root.closeHomeRequested();

                Keys.onLeftPressed: (event) => {
                    // If left-most column, focus on main bar
                    if ((model.index % gridView.columns) === 0) {
                        event.accepted = true;
                        root.focusTasksRequested();
                    } else {
                        event.accepted = false;
                    }
                }
            }
        }

        Bigscreen.Button {
            id: closeAllButton
            Layout.margins: Kirigami.Units.gridUnit
            Layout.alignment: Qt.AlignHCenter

            text: i18n("Close all apps")
            icon.name: "edit-clear-all"

            onClicked: {
                tasksModel.closeAllTasks();
            }
        }
    }
}
