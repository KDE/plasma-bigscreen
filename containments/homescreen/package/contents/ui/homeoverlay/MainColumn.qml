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

ColumnLayout {
    id: root

    property bool showTasksButton
    property bool closeControllerSuppressState

    signal minimizeAllTasksRequested()
    signal searchRequested()
    signal tasksRequested()
    signal settingsRequested()

    signal closeRequested()

    function focusTasks() {
        tasksButton.forceActiveFocus();
    }

    onVisibleChanged: {
        if (visible) {
            homeButton.forceActiveFocus();

            // Don't have controller input suppressed while the home overlay is open, so user can interact
            // Save the state to a variable
            closeControllerSuppressState = ControllerHandler.ControllerHandlerStatus.inputSuppressed;
            ControllerHandler.ControllerHandlerStatus.inputSuppressed = false;
        } else {
            // Restore controller input suppressed state (which may have been toggled here)
            ControllerHandler.ControllerHandlerStatus.inputSuppressed = closeControllerSuppressState;
        }
    }

    spacing: 0

    Kirigami.Theme.inherit: false
    Kirigami.Theme.colorSet: Kirigami.Theme.Button

    QQC2.Control {
        id: headerControl
        topPadding: Kirigami.Units.gridUnit
        bottomPadding: Kirigami.Units.gridUnit
        leftPadding: Kirigami.Units.gridUnit
        rightPadding: Kirigami.Units.gridUnit

        Layout.fillWidth: true

        background: Rectangle {
            color: Kirigami.Theme.alternateBackgroundColor
        }

        P5Support.DataSource {
            id: timeSource
            engine: "time"
            connectedSources: ["Local"]
            interval: 60000
            intervalAlignment: P5Support.Types.AlignToMinute
        }

        contentItem: ColumnLayout {
            QQC2.Label {
                id: timeLabel
                text: Qt.formatTime(timeSource.data["Local"]["DateTime"], "h:mm ap")

                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 32
                font.weight: Font.Light
            }

            QQC2.Label {
                id: dateLabel
                text: Qt.formatDate(timeSource.data["Local"]["DateTime"], "MMMM d, yyyy")

                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: Bigscreen.Units.defaultFontPixelSize
                font.weight: Font.Light
            }
        }
    }

    QQC2.Control {
        id: contentControl
        Layout.fillWidth: true
        Layout.fillHeight: true

        topPadding: Kirigami.Units.gridUnit
        bottomPadding: Kirigami.Units.gridUnit
        leftPadding: Kirigami.Units.gridUnit
        rightPadding: Kirigami.Units.gridUnit

        contentItem: ColumnLayout {
            spacing: 0

            Bigscreen.ButtonDelegate {
                id: homeButton
                Layout.fillWidth: true

                KeyNavigation.down: searchButton

                text: i18n("Home")
                icon.name: "go-home-symbolic"
                onClicked: {
                    root.minimizeAllTasksRequested();
                }
            }

            Bigscreen.ButtonDelegate {
                id: searchButton
                Layout.fillWidth: true

                KeyNavigation.down: tasksButton.downItem

                text: i18n("Search")
                icon.name: "system-search-symbolic"
                onClicked: {
                    root.searchRequested();
                }
            }

            Bigscreen.ButtonDelegate {
                id: tasksButton
                Layout.fillWidth: true

                property Item downItem: visible ? tasksButton : controllerButton.downItem
                property Item upItem: visible ? tasksButton : searchButton
                KeyNavigation.down: controllerButton.downItem
                KeyNavigation.up: searchButton

                visible: showTasksButton
                text: i18n("Tasks")
                icon.name: "transform-shear-up"

                onClicked: {
                    root.tasksRequested();
                }
            }

            Item { Layout.fillHeight: true }

            Bigscreen.SwitchDelegate {
                id: controllerButton
                Layout.fillWidth: true

                property Item downItem: visible ? controllerButton : settingsButton
                property Item upItem: visible ? controllerButton : tasksButton.upItem
                KeyNavigation.up: tasksButton.upItem
                KeyNavigation.down: settingsButton

                visible: ControllerHandler.ControllerHandlerStatus.sdlControllerConnected
                icon.name: "input-gamepad-symbolic"
                text: i18n("Controller")
                description: checked ? i18n("Currently capturing keys…") : i18n("Key capture off")

                checked: !root.closeControllerSuppressState
                onCheckedChanged: root.closeControllerSuppressState = !checked
            }

            Bigscreen.ButtonDelegate {
                id: settingsButton
                Layout.fillWidth: true
                KeyNavigation.up: controllerButton.upItem

                text: i18n("Settings")
                icon.name: "settings-configure-symbolic"
                onClicked: {
                    root.settingsRequested();
                }
            }
        }
    }
}
