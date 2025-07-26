// SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
// SPDX-FileCopyrightText: 2019 Aditya Mehra <aix.m@outlook.com>
// SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import QtQuick.Window
import Qt5Compat.GraphicalEffects

import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kquickcontrolsaddons
import org.kde.kirigami as Kirigami
import org.kde.bigscreen as Bigscreen
import org.kde.coreaddons as KCoreAddons
import org.kde.kirigamiaddons.components as KirigamiComponents

import "launcher"
import "indicators" as Indicators

Controls.Control {
    id: root

    readonly property real largeHeight: Math.min(parent.height / 2, Kirigami.Units.gridUnit * 15)
    readonly property real shrunkHeight: Kirigami.Units.gridUnit * 7

    state: "large"
    states: [
        State {
            name: "large" // When the user is at the top of the homescreen
            PropertyChanges { target: clock; state: "column" }
            PropertyChanges { target: root; height: root.largeHeight }
            PropertyChanges {
                target: root
                topPadding: Math.min(largeHeight - clock.clockBigHeight - Kirigami.Units.gridUnit * 2, Kirigami.Units.gridUnit * 6)
            }
        },
        State {
            name: "shrunk" // When the user scrolls down in the homescreen
            PropertyChanges { target: clock; state: "row" }
            PropertyChanges { target: root; height: root.shrunkHeight }
            PropertyChanges {
                target: root
                topPadding: Kirigami.Units.gridUnit * 3
            }
        }
    ]
    transitions: Transition {
        PropertyAnimation { target: root; property: 'height'; duration: 200; easing.type: Easing.InOutCubic }
        PropertyAnimation { target: root; property: 'topPadding'; duration: 200; easing.type: Easing.InOutCubic }
    }

    // Forward focus to first item
    onActiveFocusChanged: {
        if (activeFocus) {
            if (tasksIndicator.visible) {
                tasksIndicator.forceActiveFocus();
            } else {
                searchIndicator.forceActiveFocus();
            }
        }
    }

    topPadding: 0
    bottomPadding: 0
    leftPadding: 0
    rightPadding: 0

    contentItem: RowLayout {
        id: rowLayout
        spacing: Kirigami.Units.largeSpacing

        Kirigami.Theme.inherit: false
        Kirigami.Theme.colorSet: Kirigami.Theme.Complementary

        Indicators.Clock {
            id: clock
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignTop | Qt.AlignLeft
        }

        RowLayout {
            Layout.alignment: Qt.AlignTop | Qt.AlignRight
            spacing: Kirigami.Units.gridUnit

            Indicators.Tasks {
                id: tasksIndicator
                visible: taskWindowView.modelCount > 0

                KeyNavigation.right: searchIndicator
                KeyNavigation.tab: searchIndicator

                TaskWindowView {
                    id: taskWindowView
                }
            }

            Indicators.Search {
                id: searchIndicator
                KeyNavigation.left: tasksIndicator.visible ? tasksIndicator : null
                KeyNavigation.backtab: tasksIndicator.visible ? tasksIndicator : null
                KeyNavigation.right: favsIndicator
                KeyNavigation.tab: favsIndicator
            }

            Indicators.Favorites {
                id: favsIndicator
                KeyNavigation.left: searchIndicator
                KeyNavigation.backtab: searchIndicator
                KeyNavigation.right: settingsIndicator
                KeyNavigation.tab: settingsIndicator
            }

            Indicators.Settings {
                id: settingsIndicator
                KeyNavigation.left: favsIndicator
                KeyNavigation.right: volumeIndicator
                KeyNavigation.tab: volumeIndicator
                KeyNavigation.backtab: favsIndicator
            }

            Indicators.Volume {
                id: volumeIndicator
                KeyNavigation.right: batteryIndicator
                KeyNavigation.tab: batteryIndicator
                KeyNavigation.backtab: settingsIndicator
                KeyNavigation.left: settingsIndicator
            }

            Indicators.Battery {
                id: batteryIndicator
                KeyNavigation.right: wifiIndicator
                KeyNavigation.tab: wifiIndicator
                KeyNavigation.backtab: volumeIndicator
                KeyNavigation.left: volumeIndicator
            }

            Indicators.Wifi {
                id: wifiIndicator
                KeyNavigation.right: kdeConnectIndicator
                KeyNavigation.tab: kdeConnectIndicator
                KeyNavigation.backtab: batteryIndicator
                KeyNavigation.left: batteryIndicator
            }

            Indicators.KdeConnect {
                id: kdeConnectIndicator
                KeyNavigation.right: shutdownIndicator
                KeyNavigation.tab: shutdownIndicator
                KeyNavigation.backtab: wifiIndicator
                KeyNavigation.left: wifiIndicator
            }

            Indicators.Shutdown {
                id: shutdownIndicator
                KeyNavigation.backtab: kdeConnectIndicator
                KeyNavigation.left: kdeConnectIndicator
            }
        }
    }
}