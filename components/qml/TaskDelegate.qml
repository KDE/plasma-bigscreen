/*
    SPDX-FileCopyrightText: 2022 Aditya Mehra <aix.m@outlook.com>
    SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import QtQuick.Controls
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami
import org.kde.bigscreen as BigScreen

AbstractDelegate {
    id: delegate

    implicitWidth: listView.cellWidth
    implicitHeight: listView.height
    property var iconImage

    contentItem: Item {
        id: content

        GridLayout {
            id: topArea
            anchors.fill: parent
            anchors.margins: Kirigami.Units.largeSpacing
            columns: 2

            Kirigami.Icon {
                id: iconItem
                Layout.preferredWidth: parent.height * 0.75
                Layout.preferredHeight: width
                source: delegate.iconImage

                Behavior on Layout.preferredWidth {
                    ParallelAnimation {
                        NumberAnimation {
                            duration: Kirigami.Units.longDuration / 2
                            easing.type: Easing.InOutQuad
                        }
                    }
                }
            }

            Label {
                id: textLabel
                Layout.fillWidth: true
                Layout.fillHeight: true
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: width * 0.15
                font.bold: true
                maximumLineCount: 3
                wrapMode: Text.WordWrap
                elide: Text.ElideRight
                text: delegate.text
                color: Kirigami.Theme.textColor
            }
        }
    }
}
