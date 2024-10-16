
/*
    SPDX-FileCopyrightText: 2024 Aditya Mehra <aix.m@outlook.com>
    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Controls
import org.kde.kirigami as Kirigami

Kirigami.ShadowedRectangle {
    color: Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 0.8)
    radius: 6
    border.width: passwordInput.activeFocus ? 2 : 0
    border.color: passwordInput.activeFocus ? Kirigami.Theme.highlightColor : "transparent"
    property alias text: message.text
    visible: message.text != ""
    opacity: message.text != "" ? 1 : 0

    shadow {
        size: Kirigami.Units.smallSpacing
    }

    Label {
        id: message
        anchors.fill: parent
        anchors.margins: Kirigami.Units.largeSpacing
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
        font.bold: true
        font.pointSize: Kirigami.Units.gridUnit * 1.5
        color: Kirigami.Theme.textColor

        visible: opacity > 0
        opacity: text == "" ? 0 : 1
        Behavior on opacity {
            NumberAnimation {
                duration: Kirigami.Units.longDuration
            }
        }
    }
}