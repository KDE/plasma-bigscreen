// SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
// SPDX-FileCopyrightText: 2019 Aditya Mehra <aix.m@outlook.com>
// SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import QtQuick.Window

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

        // Short screens don't have room for the large clock above the first row
        readonly property bool forceShrunk: (root.height < Kirigami.Units.gridUnit * 40) || (root.width < Kirigami.Units.gridUnit * 50)
        state: (launcher.scrolledDown || forceShrunk) ? "shrunk" : "large"

        KeyNavigation.down: launcher
        KeyNavigation.tab: launcher
    }

    // Application rows
    LauncherMenu {
        id: launcher
        anchors {
            fill: parent
            topMargin: header.shrunkHeight
        }

        leftMargin: root.leftMargin
        rightMargin: root.rightMargin
        startY: {
            const minY = header.forceShrunk ? header.shrunkHeight : header.largeHeight;
            const desiredY = parent.height / 2;
            return Math.round(Math.max(minY, desiredY) - header.shrunkHeight);
        }

        KeyNavigation.backtab: header
        KeyNavigation.up: header
    }
}
