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

import "launcher"

ContainmentItem {
    id: root
    Layout.minimumWidth: Screen.desktopAvailableWidth
    Layout.minimumHeight: Screen.desktopAvailableHeight * 0.6

    property Item wallpaper

    function configureWallpaper() {
        Plasmoid.internalAction("configure").trigger();
    }

    Connections {
        target: Plasmoid.bigLauncherDbusAdapterInterface

        function onEnablePmInhibitionChanged(pmInhibition) {
            var powerInhibition = Plasmoid.bigLauncherDbusAdapterInterface.pmInhibitionActive()
            if (powerInhibition) {
                pmInhibitItem.inhibit = true
            } else {
                pmInhibitItem.inhibit = false
            }
        }
    }

    Containment.onAppletAdded: (applet, x, y) => {
        addApplet(applet, x, y);
    }

    PowerManagementItem {
        id: pmInhibitItem
    }

    Component.onCompleted: {
        for (var i in plasmoid.applets) {
            root.addApplet(plasmoid.applets[i], -1, -1)
        }
        pmInhibitItem.inhibit = Plasmoid.bigLauncherDbusAdapterInterface.pmInhibitionActive()
    }

    function addApplet(applet, x, y) {
        var container = appletContainerComponent.createObject(appletsLayout)
        print("Applet added: " + applet + " " + applet.title)

        const appletItem = root.itemFor(applet);
        appletItem.parent = container;
        container.applet = appletItem;
        appletItem.anchors.fill = container;
        appletItem.visible = true;
        appletItem.expanded = false;
    }

    Component {
        id: appletContainerComponent
        Item {
            property Item applet
            visible: applet && applet.status !== PlasmaCore.Types.HiddenStatus && applet.status !== PlasmaCore.Types.PassiveStatus
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        }
    }

    FeedbackWindow {
        id: feedbackWindow
    }

    ConfigWindow {
        id: configWindow
    }

    FavoritesManager {
        id: favsManagerWindowView
    }

    // Homescreen background
    Item {
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
            visible: opacity > 0
            opacity: homeScreen.blurBackground ? 1 : 0

            Behavior on opacity { NumberAnimation { duration: 500 } }
        }
    }

    // Background darken scrim
    Rectangle {
        anchors.fill: parent
        color: 'black'
        opacity: homeScreen.blurBackground ? 0.7 : 0.4
        Behavior on opacity { NumberAnimation { duration: 500 } }
    }

    // The homescreen's contents
    HomeScreen {
        id: homeScreen
        anchors.fill: parent
    }
}
