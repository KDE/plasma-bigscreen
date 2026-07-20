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
import org.kde.private.biglauncher
import org.kde.kirigami as Kirigami
import org.kde.bigscreen as Bigscreen

import "launcher"

FocusScope {
    id: root

    property var header
    property alias scrolledDown: launcher.scrolledDown

    readonly property real leftMargin: Kirigami.Units.gridUnit * 4
    readonly property real rightMargin: leftMargin

    // Whether to blur the wallpaper background
    readonly property bool blurBackground: launcher.scrolledDown || root.Window.activeFocusItem === null
    readonly property bool darkenBackground: launcher.scrolledDown

    property real zoomScale: 1

    property Item wallpaper

    function configureWallpaper() {
        Plasmoid.internalAction("configure").trigger();
    }

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
                OpacityAnimator { duration: 300 }
                NumberAnimation { target: root; property: 'zoomScale'; duration: 600; easing.type: Easing.OutExpo }
            }
        }
    ]

    Connections {
        target: BigLauncherDbusAdapterInterface

        function onActivateWallpaperSelectorRequested() {
            root.configureWallpaper();
        }

        // Sync D-Bus configuration changes to Plasmoid.configuration
        function onUseColoredTilesChanged(coloredTiles) {
            Plasmoid.configuration.coloredTiles = coloredTiles;
        }
        function onUseWallpaperBlurChanged(wallpaperBlur) {
            Plasmoid.configuration.wallpaperBlur = wallpaperBlur;
        }
        function onShowRecentChanged(showRecent) {
            Plasmoid.configuration.showRecent = showRecent;
        }
        function onShowApplicationsChanged(showApplications) {
            Plasmoid.configuration.showApplications = showApplications;
        }
        function onShowGamesChanged(showGames) {
            Plasmoid.configuration.showGames = showGames;
        }
    }

    StartupFeedbackWindow {
        id: feedbackWindow
    }

    FavoritesManager {
        id: favsManagerWindowView
    }

    Loader {
        id: wallpaperBlurLoader
        anchors.fill: parent
        active: Plasmoid.configuration.wallpaperBlur

        sourceComponent: Item {
            id: wallpaperBlur
            anchors.fill: parent

            // Only take samples from wallpaper when we need the blur for performance
            ShaderEffectSource {
                id: controlledWallpaperSource
                anchors.fill: parent

                sourceItem: Plasmoid.wallpaperGraphicsObject
                live: blur.visible
                hideSource: false
                visible: false
            }

            // Wallpaper blur
            // We attempted to use MultiEffect in the past, but it had very poor performance
            FastBlur {
                id: blur
                radius: 50
                cached: true
                source: controlledWallpaperSource
                anchors.fill: parent
                visible: true // Don't load and unload, which is laggy
                opacity: root.blurBackground ? 1 : 0

                Behavior on opacity { NumberAnimation { duration: 500 } }
            }
        }
    }

    // Background darken scrim
    Rectangle {
        anchors.fill: parent
        color: 'black'
        opacity: root.darkenBackground ? 0.7 : 0.4

        Behavior on opacity {
            NumberAnimation {
                duration: Kirigami.Units.longDuration
            }

        }

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

    // Applications grid
    LauncherMenu {
        id: launcher
        opacity: 0 // Displayed with launcherOpacityGradient below
        startY: {
            const minY = root.header ? root.header.largeHeight : 0; 
            const desiredY = (parent.height / 2);
            return Math.round(Math.max(minY, desiredY) - (root.header ? root.header.shrunkHeight : 0)); 
        }
        anchors {
            fill: parent
            topMargin: root.header.shrunkHeight
        }
        focus: true

        // Pass margins in so that we don't clip sides with opacity gradient
        leftMargin: root.leftMargin
        rightMargin: root.rightMargin

        KeyNavigation.backtab: root.header ? root.header.focusTarget : null
        KeyNavigation.up: root.header ? root.header.focusTarget : null
    }
}