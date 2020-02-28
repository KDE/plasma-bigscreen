/*
    Copyright 2013-2017 Jan Grulich <jgrulich@redhat.com>

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) version 3, or any
    later version accepted by the membership of KDE e.V. (or its
    successor approved by the membership of KDE e.V.), which shall
    act as a proxy defined in Section 6 of version 3 of the license.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with this library.  If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.9
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.kirigami 2.11 as Kirigami

Column {
    property var details: []

    Repeater {
        id: repeater

        property int contentHeight: 0
        property int longestString: 0

        model: details.length / 2

        Item {
            anchors {
                left: parent.left
                right: parent.right
            }
            height: Math.max(detailNameLabel.height, detailValueLabel.height)

            PlasmaComponents.Label {
                id: detailNameLabel
                anchors {
                    left: parent.left
                    leftMargin: repeater.longestString - paintedWidth + Math.round(Kirigami.Units.gridUnit / 2)
                }
                height: paintedHeight
                horizontalAlignment: Text.AlignRight
                text: details[index*2] + ": "

                Component.onCompleted: {
                    if (paintedWidth > repeater.longestString) {
                        repeater.longestString = paintedWidth
                    }
                }
            }

            PlasmaComponents.Label {
                id: detailValueLabel
                anchors {
                    left: parent.left
                    right: parent.right
                    leftMargin: repeater.longestString + Math.round(Kirigami.Units.gridUnit / 2)
                }
                height: paintedHeight
                elide: Text.ElideRight
                text: details[(index*2)+1]
                textFormat: Text.PlainText
            }
        }
    }
}
 
