/*
 *   Copyright 2015 Marco Martin <notmart@gmail.com>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Library General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtQuick.Window 2.2
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

Window {
    id: window

    function open(windowName, windowIcon) {
        window.title = windowName;
        window.icon = windowIcon;
        window.state = "open";
    }
    property alias state: background.state
    property alias icon: icon.source
    width: Screen.width
    height: Screen.height
    color: "transparent"
    onVisibleChanged: {
        if (!visible) {
            background.state = "closed";
        }
    }
    onActiveChanged: {
        if (!active) {
            background.state = "closed";
        }
    }

    Item {
        id: background
        anchors.fill: parent
        //colorGroup: PlasmaCore.Theme.ComplementaryColorGroup
        width: window.width
        height: window.height
        state: "closed"
        Rectangle {
            anchors.fill: parent
            color: background.backgroundColor

            ColumnLayout {
                anchors.centerIn: parent
                PlasmaCore.IconItem {
                    id: icon
                    colorGroup: PlasmaCore.Theme.ComplementaryColorGroup
                    Layout.preferredWidth: units.iconSizes.enormous
                    Layout.preferredHeight: Layout.preferredWidth
                    Layout.alignment: Qt.AlignCenter
                }
                PlasmaExtras.Heading {
                    text: window.title
                    Layout.alignment: Qt.AlignCenter
                }
               /* PlasmaComponents.BusyIndicator {
                    Layout.alignment: Qt.AlignCenter
                }*/
            }
        }

        states: [
            State {
                name: "closed"
                PropertyChanges {
                    target: background
                    scale: 0
                }
                PropertyChanges {
                    target: window
                    visible: false
                }
            },
            State {
                name: "open"
                PropertyChanges {
                    target: background
                    scale: 1
                }
                PropertyChanges {
                    target: window
                    visible: true
                }
            }
        ]

        transitions: [
            Transition {
                from: "closed"
                SequentialAnimation {
                    ScriptAction {
                        script: window.visible = true;
                    }
                    PropertyAnimation {
                        target: background
                        duration: units.longDuration
                        easing.type: Easing.InOutQuad
                        properties: "scale"
                    }
                }
            }
        ]
    }
}
