// SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
// SPDX-FileCopyrightText: 2019 Aditya Mehra <aix.m@outlook.com>
// SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import QtQuick.Window
import "launcher"
import org.kde.bigscreen as Bigscreen
import org.kde.kirigami as Kirigami
import org.kde.kquickcontrolsaddons
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid

Item {
    id: root

    property Item wallpaper
    readonly property real leftMargin: Kirigami.Units.gridUnit * 4
    readonly property real rightMargin: leftMargin
    // Changed from "Item" to "var" so it can access your new focusTarget property without warnings
    property var header
    readonly property bool scrolledDown: launcher.scrolledDown
    // Whether to blur the wallpaper background
    readonly property bool blurBackground: launcher.scrolledDown || root.Window.activeFocusItem === null
    readonly property bool darkenBackground: launcher.scrolledDown
    property real zoomScale: 1

    // --- NEW FIX: Clean Focus Handling ---
    // This perfectly passes the cursor into the app grid when you press "Down" from the Navbar
    onActiveFocusChanged: {
        if (activeFocus)
            launcher.forceActiveFocus();

    }

    Connections {
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

        target: BigLauncherDbusAdapterInterface
    }
    // Applications grid

    LauncherMenu {
        id: launcher

        // --- NEW FIX: Mouse Scrolling ---
        // Change back to 0 if you want the visual gradient on a real TV,
        // but keep at 1 while testing on a computer so your mouse wheel works!
        opacity: 1
        startY: {
            const minY = header ? header.largeHeight : 0;
            const desiredY = (parent.height / 2);
            return Math.round(Math.max(minY, desiredY) - (header ? header.shrunkHeight : 0));
        }
        // Pass margins in so that we don't clip sides with opacity gradient
        leftMargin: root.leftMargin
        rightMargin: root.rightMargin
        // --- NEW FIX: Point the Up arrow to the exact Search Icon ---
        KeyNavigation.backtab: header ? header.focusTarget : null
        KeyNavigation.up: header ? header.focusTarget : null

        anchors {
            fill: parent
            topMargin: header ? header.shrunkHeight : 0
        }

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
                opacity: homeScreen.blurBackground ? 1 : 0

                Behavior on opacity {
                    NumberAnimation {
                        duration: Kirigami.Units.longDuration
                    }

                }

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

            property real gradientPct: (Kirigami.Units.gridUnit * 2) / launcher.height

            width: launcher.width
            height: launcher.height

            gradient: Gradient {
                GradientStop {
                    position: 0
                    color: 'transparent'
                }

                GradientStop {
                    position: mask.gradientPct
                    color: 'white'
                }

                GradientStop {
                    position: 1
                    color: 'white'
                }

            }

        }

    }

    transform: Scale {
        origin.x: root.width / 2
        origin.y: root.height / 2
        xScale: root.zoomScale
        yScale: root.zoomScale
    }

}
