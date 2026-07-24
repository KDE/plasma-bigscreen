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

FocusScope {
    id: root

    property var header
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

    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.6) 
        z: -1 
    }
    
    Item {
        id: heroWallpaperContainer
        z: -2
        anchors.fill: parent

        property string currentHero: launcher.activeHeroPath

        onCurrentHeroChanged: {
            if (frontImage.status === Image.Ready) {
                backImage.source = frontImage.source;
            }
            frontImage.source = currentHero;
        }

        Image {
            id: backImage
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
        }

        Image {
            id: frontImage
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            
            opacity: status === Image.Ready ? 1 : 0

            Behavior on opacity {
                NumberAnimation { 
                    duration: Kirigami.Units.longDuration 
                    easing.type: Easing.OutCubic
                }
            }
        }
    }

}