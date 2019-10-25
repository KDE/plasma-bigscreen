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
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3 as Controls
import QtQuick.Window 2.2
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.kquickcontrolsaddons 2.0
import org.kde.kirigami 2.5 as Kirigami

Rectangle {
    anchors.fill: parent
    color: Kirigami.Theme.backgroundColor
    anchors.topMargin: Kirigami.Units.gridUnit * 10
    anchors.bottomMargin: Kirigami.Units.gridUnit * 10

    Item {
        width: parent.width
        height: parent.height

        GridView {
            id: gridSettingsView
            layoutDirection: Qt.LeftToRight
            width: parent.width
            height: parent.height
            flow: GridView.FlowTopToBottom
            cellWidth: gridSettingsView.width / 3
            cellHeight: gridSettingsView.height / 1
            clip: true
            model: ListModel {
                ListElement { name: "Wireless"; icon: "network-wireless-connected-100"}
                ListElement { name: "Preferences"; icon: "dialog-scripts"}
                ListElement { name: "Mycroft"; icon: "mycroft"}
            }
            delegate: RowSettingsDelegate{}
        }
    }
}
