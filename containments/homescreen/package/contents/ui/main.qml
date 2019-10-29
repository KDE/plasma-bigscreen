/*
 * Copyright 2019 Aditya Mehra <aix.m@outlook.com>
 * Copyright 2015 Marco Martin <mart@kde.org>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  2.010-1301, USA.
 */

import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3 as Controls
import QtQuick.Window 2.3
import org.kde.plasma.plasmoid 2.0

import org.kde.kquickcontrolsaddons 2.0
import org.kde.kirigami 2.5 as Kirigami
import Mycroft 1.0 as Mycroft

import "launcher"
import "indicators" as Indicators

Item {
    id: root
    Layout.minimumWidth: Screen.desktopAvailableWidth
    Layout.minimumHeight: Screen.desktopAvailableHeight * 0.6


    MycroftWindow {
        id: mycroftWindow
    }

    Rectangle {
        anchors {
            left: parent.left
            top: parent.top
            right: parent.right
        }
        height: units.iconSizes.medium + units.smallSpacing * 2
        opacity: !mycroftWindow.visible

        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.rgba(0, 0, 0, 0.6) }
            GradientStop { position: 1; color: "transparent" }
        }
        Behavior on opacity {
            OpacityAnimator {
                duration: units.longDuration
                easing.type: Easing.InOutQuad
            }
        }

        RowLayout {
            anchors {
                right: parent.right
                top: parent.top
                bottom: parent.bottom
                margins: units.smallSpacing
            }
            Indicators.Wifi {
                Layout.fillHeight: true
                implicitWidth: height
                anchors.centerIn: mycroftIndicator
            }
        }
    }

    LauncherMenu {
        id: launcher
        width: parent.width
        height: parent.height
    

        states: [
            State {
                when: !mycroftWindow.visible
                PropertyChanges {
                    target: launcher
                    opacity: 1
                    y: 0
                }
            },
            State {
                when: mycroftWindow.visible
                PropertyChanges {
                    target: launcher
                    opacity: 0
                    y: root.height / 4
                }
            }
        ]

        transitions: [
            Transition {
                ParallelAnimation {
                    OpacityAnimator {
                        duration: units.longDuration
                        easing.type: Easing.InOutQuad
                    }
                    YAnimator {
                        duration: units.longDuration
                        easing.type: Easing.InOutQuad
                    }
                }
            }
        ]
    }

    Mycroft.StatusIndicator {
        id: mycroftIndicator
        z: 2
        visible: !mycroftWindow.visible
        anchors {
            right: parent.right
            top: parent.top
            margins: Kirigami.Units.largeSpacing
            topMargin: Kirigami.Units.largeSpacing + plasmoid.availableScreenRect.y
        }
    }
}
