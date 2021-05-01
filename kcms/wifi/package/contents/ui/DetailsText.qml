/*
    SPDX-FileCopyrightText: 2013-2017 Jan Grulich <jgrulich@redhat.com>

    SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL
*/

import QtQuick 2.14
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.kirigami 2.12 as Kirigami

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
 
