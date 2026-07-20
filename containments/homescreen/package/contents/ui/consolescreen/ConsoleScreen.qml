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

FocusScope {
    id: root

    property var header
    property Item wallpaper
    property real zoomScale: 1 

    readonly property real leftMargin: Kirigami.Units.gridUnit * 4
    readonly property real rightMargin: leftMargin

    transform: Scale {
        origin.x: root.width / 2;
        origin.y: root.height / 2;
        xScale: root.zoomScale
        yScale: root.zoomScale
    }

    states: [
        State {
            name: "focused"
            when: root.StackLayout.isCurrentItem && root.Window.activeFocusItem !== null

            PropertyChanges {
                target: root
                opacity: 1
                zoomScale: 1
            }
            // StateChangeScript {
            //     script: Qt.callLater(function() {
            //         if (launcher) {
            //             launcher.forceActiveFocus();
            //         }
            //     })
            // }
        },
        State {
            name: "unfocused"
            when: !root.StackLayout.isCurrentItem || root.Window.activeFocusItem === null
            PropertyChanges {
                target: root
                opacity: 0
                zoomScale: 1.1
            }
            StateChangeScript {
                // HACK: Kill xwaylandvideobridge if running - it interferes with bigscreen's focus
                script: Plasmoid.executeCommand("pkill -f xwaylandvideobridge")
            }
        }
    ]

    transitions: [
        Transition {
            to: "focused"
            ParallelAnimation {
                OpacityAnimator { duration: Kirigami.Units.shortDuration }
                NumberAnimation { target: root; property: 'zoomScale'; duration: Kirigami.Units.longDuration; easing.type: Easing.OutExpo }
            }
        }
    ]

    StartupFeedbackWindow {
        id: feedbackWindow
    }

    // Games grid
    LauncherMenu {
        id: launcher
        opacity: 0 // Displayed with launcherOpacityGradient below
        anchors {
            fill: parent
            topMargin: root.header ? root.header.shrunkHeight : 0
        }
        focus: true
        // Pass margins in so that we don't clip sides with opacity gradient
        leftMargin: root.leftMargin
        rightMargin: root.rightMargin

        KeyNavigation.backtab: root.header ? root.header.focusTarget : null
        KeyNavigation.up: root.header ? root.header.focusTarget : null
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