// SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import QtQuick.Effects

import org.kde.kirigami as Kirigami

Item {
    id: root
    property var control
    property bool raisedBackground: true

    property color neutralBackgroundColor: Kirigami.Theme.backgroundColor

    Rectangle {
        id: frame
        anchors.fill: parent
        color: (root.control.enabled && root.control.activeFocus) ? Kirigami.Theme.activeBackgroundColor : (raisedBackground ? root.neutralBackgroundColor : 'transparent')
        border.width: root.control.activeFocus ? 2 : 1
        border.color: root.control.activeFocus ? Kirigami.Theme.highlightColor : (raisedBackground ? 'transparent' : Qt.darker(color, 1.2))
        radius: Kirigami.Units.cornerRadius
    }

    MultiEffect {
        id: frameShadow
        visible: root.raisedBackground

        anchors.fill: frame
        source: frame
        blurMax: 16
        shadowEnabled: true
        shadowOpacity: 0.6
        shadowColor: 'black'
    }
}