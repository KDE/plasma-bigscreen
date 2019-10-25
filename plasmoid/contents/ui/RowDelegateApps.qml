/*
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
import QtQuick.Controls 2.3 as Controls

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.kquickcontrolsaddons 2.0
import org.kde.kirigami 2.5 as Kirigami

Controls.Control {
    width: gridView.cellWidth
    height: gridView.cellHeight
    property var appStorageIdRole: modelData.ApplicationStorageIdRole
    
    background: PlasmaCore.FrameSvgItem {
        id: frame
        imagePath: "widgets/background"
        anchors.fill: parent
    }
    
    contentItem: Item {
        ColumnLayout {
            width: gridView.cellWidth
            anchors.centerIn: parent
        
            Kirigami.Icon {
                id: icon
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                Layout.fillWidth: true
                Layout.preferredHeight: gridView.cellHeight - (root.reservedSpaceForLabel + Kirigami.Units.largeSpacing)
                source: modelData ? modelData.ApplicationIconRole : ""
                //scale: 1 //root.reorderingApps //&& dragDelegate && !dragging ? 0.6 : 1
                Behavior on scale {
                    NumberAnimation {
                        duration: units.longDuration
                        easing.type: Easing.InOutQuad
                    }
                }
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
        
                text: modelData ? modelData.ApplicationNameRole : ""
                font.pixelSize: theme.defaultFont.pixelSize
                color: PlasmaCore.ColorScope.textColor
            }
        }
        
        MouseArea {
            anchors.fill: parent
            propagateComposedEvents: true
            //preventStealing: true
            onClicked: {
                gridView.forceActiveFocus()
                console.log(index)
                gridView.currentIndex = index
                console.log(gridView.currentIndex)
		root.appsModel.runApplication(modelData.ApplicationStorageIdRole)
            }
        }
    }
}
