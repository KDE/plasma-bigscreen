/*
    SPDX-FileCopyrightText: 2015 Marco Martin <notmart@gmail.com>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Window
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.extras as PlasmaExtras
import org.kde.kirigami as Kirigami

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
        Kirigami.Theme.inherit: false
        Kirigami.Theme.colorSet: Kirigami.Theme.Complementary
        width: window.width
        height: window.height
        state: "closed"

        Rectangle {
            anchors.fill: parent
            color: Kirigami.Theme.backgroundColor

            ColumnLayout {
                anchors.centerIn: parent
                Kirigami.Icon {
                    id: icon
                    Kirigami.Theme.inherit: false
                    Kirigami.Theme.colorSet: Kirigami.Theme.Complementary
                    Layout.preferredWidth: Kirigami.Units.iconSizes.enormous
                    Layout.preferredHeight: Layout.preferredWidth
                    Layout.alignment: Qt.AlignCenter
                }
                PlasmaExtras.Heading {
                    text: window.title
                    Layout.alignment: Qt.AlignCenter
                }
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
