// SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
// SPDX-FileCopyrightText: 2019 Aditya Mehra <aix.m@outlook.com>
// SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import "../indicators" as Indicators
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import QtQuick.Window
import org.kde.bigscreen as Bigscreen
import org.kde.coreaddons as KCoreAddons
import org.kde.kirigami as Kirigami
import org.kde.kirigamiaddons.components as KirigamiComponents
import org.kde.kquickcontrolsaddons
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid

Controls.Control {
    id: root
    
    property alias focusTarget: searchIndicator
    property Item downFocusItem
    readonly property real largeHeight: Math.min(parent.height / 2, Kirigami.Units.gridUnit * 15)
    readonly property real shrunkHeight: Kirigami.Units.gridUnit * 7

    state: "large"
    topPadding: 0
    bottomPadding: 0
    leftPadding: 0
    rightPadding: 0
    states: [
        State {
            name: "large"

            PropertyChanges {
                target: clock
                state: "column"
            }

            PropertyChanges {
                target: root
                height: root.largeHeight
            }

            PropertyChanges {
                target: root
                topPadding: Math.min(largeHeight - clock.clockBigHeight - Kirigami.Units.gridUnit * 2, Kirigami.Units.gridUnit * 6)
            }

        },
        State {
            name: "shrunk" // When the user scrolls down in the homescreen

            PropertyChanges {
                target: clock
                state: "row"
            }

            PropertyChanges {
                target: root
                height: root.shrunkHeight
            }

            PropertyChanges {
                target: root
                topPadding: Kirigami.Units.gridUnit * 1
            }

        }
    ]

    transitions: Transition {
        PropertyAnimation {
            target: root
            property: 'height'
            duration: 200
            easing.type: Easing.InOutCubic
        }

        PropertyAnimation {
            target: root
            property: 'topPadding'
            duration: 200
            easing.type: Easing.InOutCubic
        }

    }

    contentItem: Item {
        id: container

        // 1. LEFT: The Clock
        Indicators.Clock {
            id: clock

            anchors.left: parent.left
            anchors.top: parent.top
        }



        // 3. RIGHT: The Indicator Icons
        RowLayout {
            anchors.right: parent.right
            anchors.top: parent.top
            spacing: Kirigami.Units.gridUnit * root.scaleFactor

            Indicators.Search {
                id: searchIndicator

                Layout.preferredWidth: 32 * root.scaleFactor
                Layout.preferredHeight: 32 * root.scaleFactor
                KeyNavigation.right: settingsIndicator
                KeyNavigation.tab: settingsIndicator
                KeyNavigation.down: root.downFocusItem
            }

            Indicators.Settings {
                id: settingsIndicator

                Layout.preferredWidth: 32 * root.scaleFactor
                Layout.preferredHeight: 32 * root.scaleFactor
                KeyNavigation.left: searchIndicator
                KeyNavigation.backtab: searchIndicator
                KeyNavigation.right: shutdownIndicator
                KeyNavigation.tab: shutdownIndicator
                KeyNavigation.down: root.downFocusItem
            }

            Indicators.Shutdown {
                id: shutdownIndicator

                Layout.preferredWidth: 32 * root.scaleFactor
                Layout.preferredHeight: 32 * root.scaleFactor
                KeyNavigation.left: settingsIndicator
                KeyNavigation.backtab: settingsIndicator
                KeyNavigation.down: root.downFocusItem
            }

        }

    }

}
