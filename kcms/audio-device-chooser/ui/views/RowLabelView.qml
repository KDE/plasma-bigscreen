/*
    SPDX-FileCopyrightText: 2019 Aditya Mehra <aix.m@outlook.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import Qt5Compat.GraphicalEffects
import QtQuick.Layouts

import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.extras as PlasmaExtras

import org.kde.kirigami as Kirigami

Item {
    id: rowLabel
    Layout.leftMargin: -Kirigami.Units.gridUnit * 1
    Layout.preferredWidth: parent.width / 5
    Layout.fillHeight: true
    z: 100
    property alias text: deviceTypeHeading.text
    property alias color: rowLabelBg.color
    
    Rectangle {
        id: rowLabelBg
        anchors.fill: parent

        Kirigami.Heading {
            id: deviceTypeHeading
            //enabled: sinkView.count > 0
            anchors.centerIn: parent
            level: 3
        }

        DropShadow {
            anchors.fill: deviceTypeHeading
            horizontalOffset: 0
            verticalOffset: 2
            radius: 8.0
            samples: 17
            color: Qt.rgba(0,0,0,0.6)
            source: deviceTypeHeading
        }
    }
    
    DropShadow {
        anchors.fill: rowLabelBg
        horizontalOffset: 0
        verticalOffset: 2
        radius: 8.0
        samples: 17
        color: Qt.rgba(0,0,0,0.6)
        source: rowLabelBg
    }
}
