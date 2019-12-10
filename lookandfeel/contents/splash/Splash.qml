/*
 *   Copyright 2016 Alexis Lopez Zubieta <azubieta90@gmail.com>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License version 2,
 *   or (at your option) any later version, as published by the Free
 *   Software Foundation
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 2.5
import QtGraphicalEffects 1.0

Rectangle {
    id: root
    color: "#FAFAFA"

    property int stage


    Item {
        clip: true

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.verticalCenter
        anchors.bottomMargin: logo.size / 8
        width: 300
        height: 80

        Image {
            id: rocket
            property real size: units.gridUnit * 2

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: -20

            source: "images/rocket.svg"

            sourceSize.width: size
            sourceSize.height: size

            states: [
                State {
                    name: "1"
                    when: root.stage >= 1 && root.stage < 6
                    PropertyChanges {
                        target: rocket
                        anchors.bottomMargin: 80
                    }
                },
                State {
                    name: "4"
                    when: root.stage >= 6
                    PropertyChanges {
                        target: rocket
                        anchors.bottomMargin: 90
                    }
                }
            ]

            transitions: Transition {
                NumberAnimation {
                    properties: "anchors.bottomMargin"
                    easing.type: Easing.InOutQuad
                    duration: 1000
                }
            }
        }
    }

    Item {
        id: logoBox
        clip: true
        width: 200
        height: 60

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.verticalCenter
        anchors.topMargin: -15

        Image {
            id: logo
            property real size: units.gridUnit * 8

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top

            source: "images/logo.svg"

            sourceSize.width: size
            sourceSize.height: size

            states: [
                State {
                    when: root.stage >= 1 && root.stage < 5
                    PropertyChanges {
                        target: logo
                        anchors.topMargin: 15
                    }
                },
                State {
                    when: root.stage >= 5
                    PropertyChanges {
                        target: logo
                        anchors.topMargin: (logo.size + 30) * -1;
                    }
                }
            ]

            transitions: Transition {
                NumberAnimation {
                    properties: "anchors.topMargin"
                    easing.type: Easing.InOutQuad
                    duration: 1000
                }
            }
        }

        states: [
            State {
                name: "1"
                when: root.stage >= 1
                PropertyChanges {
                    target: logoBox
                    anchors.topMargin: 15
                }
            }
        ]

        transitions: Transition {
            NumberAnimation {
                properties: "anchors.topMargin"
                easing.type: Easing.InOutQuad
                duration: 1000
            }
        }
    }


    Rectangle {
        id: glowingBar
        anchors.centerIn: root

        width: 200
        height: 5

        radius: 6
        opacity: 0


        gradient: Gradient {
            GradientStop { position: 0.0; color: "transparent" }
            GradientStop { position: 0.33; color: "#16BDD2" }
            GradientStop { position: 0.66; color: "#16BDD2" }
            GradientStop { position: 1.0; color: "transparent" }
        }

        states: [
            State {
                name: "3"
                when: root.stage >= 3
                PropertyChanges {
                    target: glowingBar
                    opacity: 1
                }
            }
        ]

        transitions: Transition {
            NumberAnimation {
                properties: "opacity"
                easing.type: Easing.InOutQuad
                duration: 1000
            }
        }

    }

    Item {
        id: welcomeMessageBox

        width: 200;
        height: welcomeMessage.height

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: glowingBar.top

        clip: true

        Text {
            id: welcomeMessage
            text: i18n("Welcome")
            color: "#212121"
            font.pointSize: 18
            font.weight: Font.Light

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: welcomeMessage.height

            states: [
                State {
                    name: "visible"
                    when: root.stage >= 6
                    PropertyChanges {
                        target: welcomeMessage
                        anchors.topMargin: - 5
                    }
                }
            ]

            transitions: Transition {
                NumberAnimation {
                    properties: "anchors.topMargin"
                    easing.type: Easing.InOutQuad
                    duration: 1000
                }
            }
        }
    }
}
