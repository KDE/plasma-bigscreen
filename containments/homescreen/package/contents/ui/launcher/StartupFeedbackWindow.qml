// SPDX-FileCopyrightText: 2015 Marco Martin <notmart@gmail.com>
// SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Window
import QtQuick.Effects

import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.extras as PlasmaExtras
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PC3
import org.kde.plasma.private.nanoshell as NanoShell
import org.kde.plasma.plasmoid

NanoShell.FullScreenOverlay {
    id: window

    Connections {
        target: Plasmoid

        function onShowAppLaunchScreenRequested(appName, icon) {
            window.open(appName, icon);
        }
    }

    function open(windowName, windowIcon) {
        window.visible = false;
        window.title = windowName;
        window.icon = windowIcon;
        window.state = "open";
        window.showMaximized();
    }

    property alias state: windowRoot.state
    property alias icon: icon.source

    color: "transparent"

    onVisibleChanged: {
        if (!visible) {
            window.state = "closed";
        } else {
            windowRoot.forceActiveFocus();
        }
    }
    onActiveChanged: {
        if (!active) {
            window.state = "closed";
            window.close();
        }
    }

    FocusScope {
        id: windowRoot
        anchors.fill: parent

        Keys.onEscapePressed: {
            window.state = "closed";
            window.close();
        }

        Rectangle {
            id: background
            anchors.fill: parent

            // Tint the background color if a dark theme is being used
            color: Kirigami.ColorUtils.brightnessForColor(Kirigami.Theme.backgroundColor) === Kirigami.ColorUtils.Dark ?
                    Kirigami.ColorUtils.tintWithAlpha(colorGenerator.dominant, Kirigami.Theme.backgroundColor, 0.7) :
                    colorGenerator.dominant

            Kirigami.ImageColors {
                id: colorGenerator
                source: icon.source
            }
        }

        Item {
            id: iconParent
            anchors.centerIn: background
            width: Kirigami.Units.iconSizes.enormous
            height: Kirigami.Units.iconSizes.enormous

            Kirigami.Icon {
                id: icon
                anchors.fill: parent
            }

            MultiEffect {
                anchors.fill: icon
                source: icon
                shadowEnabled: true
                blurMax: 16
                shadowColor: "#80000000"
            }

            // Show loading indicator after two seconds have passed
            PC3.BusyIndicator {
                id: loadingIndicator
                anchors.top: icon.bottom
                anchors.horizontalCenter: icon.horizontalCenter
                anchors.topMargin: Kirigami.Units.gridUnit

                implicitHeight: Kirigami.Units.iconSizes.smallMedium
                implicitWidth: Kirigami.Units.iconSizes.smallMedium
            }
        }

        state: 'closed'
        states: [
            State {
                name: "closed"
                PropertyChanges {
                    target: windowRoot
                    opacity: 0
                }
                PropertyChanges {
                    target: window
                    visible: false
                }
            },
            State {
                name: "open"
                PropertyChanges {
                    target: windowRoot
                    opacity: 1
                }
            }
        ]

        transitions: [
            Transition {
                from: "closed"
                SequentialAnimation {
                    PropertyAnimation {
                        target: windowRoot
                        duration: Kirigami.Units.longDuration
                        easing.type: Easing.InOutQuad
                        properties: "opacity"
                    }
                }
            }
        ]
    }
}
