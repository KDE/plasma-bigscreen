/*
 * Copyright 2019 Aditya Mehra <aix.m@outlook.com>
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
import QtGraphicalEffects 1.12
import QtQuick.Layouts 1.3

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

import org.kde.kirigami 2.5 as Kirigami

Rectangle {
    id: rowLabel
    Layout.leftMargin: -Kirigami.Units.gridUnit * 1
    Layout.preferredWidth: parent.width / 5
    Layout.fillHeight: true
    z: 100
    property alias text: deviceTypeHeading.text

    Kirigami.Heading {
        id: deviceTypeHeading
        enabled: sinkView.count > 0
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
