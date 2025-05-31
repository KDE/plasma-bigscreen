/*
    SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2019 Aditya Mehra <aix.m@outlook.com>
    SPDX-FileCopyrightText: 2025 Seshan Ravikumar <seshan@sineware.ca>

    SPDX-License-Identifier: GPL-2.0-or-later
*/


import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami

Controls.Button {
    id: delegateButton
    height: Kirigami.Units.gridUnit * 4
    property var modelItem
    property string modelActionIcon: ""

    background: Rectangle {
        color: delegateButton.activeFocus ? Kirigami.Theme.highlightColor : Kirigami.Theme.backgroundColor
        border.color: Kirigami.Theme.disabledTextColor
        border.width: 1
    }

    contentItem: Item {
        RowLayout {
            anchors.fill: parent
            anchors.margins: Kirigami.Units.largeSpacing
            spacing: Kirigami.Units.largeSpacing

            Kirigami.Icon {
                Layout.fillHeight: true
                Layout.preferredWidth: height
                source: modelItem ? modelItem.ApplicationIconRole : ""
            }

            Controls.Label {
                Layout.fillHeight: true
                Layout.fillWidth: true
                fontSizeMode: Text.Fit
                minimumPixelSize: 8
                font.pixelSize: 18
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignLeft
                text: modelItem ? modelItem.ApplicationNameRole : ""
            }

            Kirigami.Icon {
                Layout.fillHeight: true
                Layout.preferredWidth: height
                Layout.alignment: Qt.AlignRight
                source: modelActionIcon
            }
        }
    }

    Keys.onReturnPressed: {
        clicked();
    }
}