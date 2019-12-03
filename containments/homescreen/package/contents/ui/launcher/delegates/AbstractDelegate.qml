/*
 *  Copyright 2019 Aditya Mehra <aix.m@outlook.com>
 *  Copyright 2019 Marco Martin <mart@kde.org>
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

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kirigami 2.11 as Kirigami

Kirigami.AbstractCard {
    id: delegate

    implicitWidth: listView.cellWidth
    implicitHeight: listView.height
    property string icon

    readonly property ListView listView: ListView.view

    checked: listView.currentIndex == index
    z: listView.currentIndex == index ? 2 : 0
    onClicked: {
        listView.forceActiveFocus()
        console.log(index)
        listView.currentIndex = index
        console.log(listView.currentIndex)
    }

    contentItem: ColumnLayout {
        spacing: 0
        PlasmaCore.IconItem {
            id: icon
            Layout.fillWidth: true
            Layout.fillHeight: true
            source: delegate.icon
        }

        PlasmaComponents.Label {
            id: label
            visible: text.length > 0
    
            Layout.fillWidth: true
            Layout.preferredHeight: root.reservedSpaceForLabel
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            maximumLineCount: 2
            elide: Text.ElideRight
            color: PlasmaCore.ColorScope.textColor

            text: delegate.text
        }
    }
}
