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

import "launcher"

Item {
    id: root

    readonly property real leftMargin: Kirigami.Units.gridUnit * 4
    readonly property real rightMargin: leftMargin

    // Whether to blur the wallpaper background
    readonly property bool blurBackground: launcher.scrolledDown || root.Window.activeFocusItem === null
    readonly property bool darkenBackground: launcher.scrolledDown

    property real zoomScale: 1

    transform: Scale {
        origin.x: root.width / 2;
        origin.y: root.height / 2;
        xScale: root.zoomScale
        yScale: root.zoomScale
    }

    states: [
        State {
            name: "focused"
            when: root.Window.activeFocusItem !== null

            PropertyChanges {
                target: root
                opacity: 1
                zoomScale: 1
            }
            StateChangeScript {
                script: launcher.forceActiveFocus()
            }
        },
        State {
            name: "unfocused"
            when: root.Window.activeFocusItem === null

            PropertyChanges {
                target: root
                opacity: 0
                zoomScale: 1.1
            }
        }
    ]

    transitions: [
        Transition {
            to: "focused"
            ParallelAnimation {
                OpacityAnimator { duration: 300 }
                NumberAnimation { target: root; property: 'zoomScale'; duration: 600; easing.type: Easing.OutExpo }
            }
        }
    ]

    HomeHeader {
        id: header
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            leftMargin: root.leftMargin
            rightMargin: root.rightMargin
        }

        state: launcher.scrolledDown ? "shrunk" : "large"

        KeyNavigation.down: launcher
        KeyNavigation.tab: launcher
    }

    // Applications grid
    LauncherMenu {
        id: launcher
        opacity: 0 // Displayed with launcherOpacityGradient below
        startY: {
            const minY = header.largeHeight; // Right after the HomeHeader at max height
            const desiredY = (parent.height / 2);
            return Math.round(Math.max(minY, desiredY) - header.shrunkHeight); // Adjust for anchors.topMargin
        }
        anchors {
            fill: parent
            topMargin: header.shrunkHeight
        }

        // Pass margins in so that we don't clip sides with opacity gradient
        leftMargin: root.leftMargin
        rightMargin: root.rightMargin

        KeyNavigation.backtab: header
        KeyNavigation.up: header
    }

    // Opacity "fade" effect at edges
    OpacityMask {
        id: launcherOpacityGradient
        anchors.fill: launcher

        source: launcher
        maskSource: Rectangle {
            id: mask
            width: launcher.width
            height: launcher.height

            property real gradientPct: (Kirigami.Units.gridUnit * 2) / launcher.height

            gradient: Gradient {
                GradientStop { position: 0.0; color: 'transparent' }
                GradientStop { position: mask.gradientPct; color: 'white' }
                GradientStop { position: 1.0; color: 'white' }
            }
        }
    }
}