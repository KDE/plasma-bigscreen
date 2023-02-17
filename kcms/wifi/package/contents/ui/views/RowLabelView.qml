/*
    SPDX-FileCopyrightText: 2019 Aditya Mehra <aix.m@outlook.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.15
import QtQuick.Layouts 1.15

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.kirigami 2.19 as Kirigami
import Qt5Compat.GraphicalEffects

Rectangle {
    id: rowLabel
    Layout.bottomMargin: -Kirigami.Units.gridUnit * 2
    Layout.topMargin: -Kirigami.Units.gridUnit * 0.4
    Layout.leftMargin: -Kirigami.Units.gridUnit * 1
    Layout.preferredWidth: parent.width / 5
    Layout.fillHeight: true
    z: 100
    property alias text: deviceTypeHeading.text

    Kirigami.Heading {
        id: deviceTypeHeading
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
