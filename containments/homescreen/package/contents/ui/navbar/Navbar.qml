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
    readonly property real shrunkHeight: Kirigami.Units.gridUnit * 4
    state: "large"
    topPadding: Kirigami.Units.gridUnit
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

        }
    ]

    transitions: Transition {
        PropertyAnimation {
            target: root
            property: 'height'
            duration: Kirigami.Units.shortDuration
            easing.type: Easing.InOutCubic
        }

        PropertyAnimation {
            target: root
            property: 'topPadding'
            duration: Kirigami.Units.shortDuration
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
                KeyNavigation.right: volumeIndicator
                KeyNavigation.tab: volumeIndicator
                KeyNavigation.down: root.downFocusItem
            }

            Indicators.Volume {
                id: volumeIndicator
                KeyNavigation.left: searchIndicator
                KeyNavigation.backtab: searchIndicator
                KeyNavigation.right: wifiIndicator
                KeyNavigation.tab: wifiIndicator
                KeyNavigation.down: root.downFocusItem
                
            }
            
            Indicators.Wifi {
                id: wifiIndicator
                KeyNavigation.left: volumeIndicator
                KeyNavigation.backtab: volumeIndicator
                KeyNavigation.right: bluetoothIndicator
                KeyNavigation.tab: bluetoothIndicator
                KeyNavigation.down: root.downFocusItem
            }

            Indicators.Bluetooth {
                id: bluetoothIndicator
                KeyNavigation.left: wifiIndicator
                KeyNavigation.backtab: wifiIndicator
                KeyNavigation.right: kdeConnectIndicator
                KeyNavigation.tab: kdeConnectIndicator
                KeyNavigation.down: root.downFocusItem
            }

            Indicators.KdeConnect {
                id: kdeConnectIndicator
                KeyNavigation.left: bluetoothIndicator
                KeyNavigation.backtab: bluetoothIndicator
                KeyNavigation.right: batteryIndicator
                KeyNavigation.tab: batteryIndicator
                KeyNavigation.down: root.downFocusItem
            }

            Indicators.Battery {
                id: batteryIndicator
                KeyNavigation.left: kdeConnectIndicator
                KeyNavigation.backtab: kdeConnectIndicator
                KeyNavigation.down: root.downFocusItem
            }


        }

    }

}
