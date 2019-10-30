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

import QtQuick 2.12
import QtQuick.Layouts 1.4
import QtQuick.Controls 2.4 as Controls

import org.kde.private.biglauncher 1.0 as Launcher
import org.kde.kirigami 2.5 as Kirigami


ListView {
    id: view
    property int columns: 3

    readonly property int cellWidth: width / columns

    Layout.fillWidth: true
    Layout.fillHeight: true

    keyNavigationEnabled: true
    keyNavigationWraps: true
    highlightRangeMode: ListView.ApplyRange
    highlightFollowsCurrentItem: true
    snapMode: ListView.SnapToItem

    preferredHighlightBegin: width/view.columns
    preferredHighlightEnd: width/view.columns * 2

    highlightMoveDuration: Kirigami.Units.longDuration

    spacing: 0
    orientation: ListView.Horizontal

    move: Transition {
        SmoothedAnimation {
            property: "x"
            duration: Kirigami.Units.longDuration
        }
    }
}
/*
GridView {
    Layout.fillWidth: true
    Layout.preferredHeight: parent.height / 3 - launcherHomeColumn.columnLabelHeight
    layoutDirection: Qt.LeftToRight
    flow: GridView.FlowTopToBottom
    cellWidth: width / 3
    cellHeight: height / 1
    clip: true
    keyNavigationEnabled: false
    highlight: focus == true ? launcherHomeColumn.activeHighlightItem : launcherHomeColumn.disabledHighlightItem
    highlightFollowsCurrentItem: true
    property var appId
    property int lastItemIndex
    
    move: Transition {
        NumberAnimation { properties: "x,y"; duration: 0 }
    }
}
*/
