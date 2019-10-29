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
import org.kde.kirigami 2.5 as Kirigami

PlasmaComponents.ItemDelegate {
    id: delegate

    width: gridView.cellWidth
    height: gridView.cellHeight

    readonly property GridView gridView: GridView.view

    onClicked: {
        gridView.forceActiveFocus()
        console.log(index)
        gridView.currentIndex = index
        console.log(gridView.currentIndex)
    }

    background: PlasmaCore.FrameSvgItem {
        id: frame
        imagePath: "widgets/background"
    }
    
    contentItem: ColumnLayout {
        Kirigami.Icon {
            id: icon
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            Layout.fillWidth: true
            Layout.preferredHeight: gridView.cellHeight - (root.reservedSpaceForLabel + Kirigami.Units.largeSpacing)
            source: delegate.icon.name || delegate.icon.source
        }

        PlasmaComponents.Label {
            id: label
            visible: text.length > 0
    
            Layout.fillWidth: true
            Layout.fillHeight: true
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignTop
            maximumLineCount: 2
            elide: Text.ElideRight
            color: PlasmaCore.ColorScope.textColor

            text: delegate.text
        }
    }
}
