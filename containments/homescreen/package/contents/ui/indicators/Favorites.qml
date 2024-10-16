/*
    SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2019 Aditya Mehra <aix.m@outlook.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.bigscreen as BigScreen
import org.kde.kirigami as Kirigami

AbstractIndicator {
    id: favsIcon

    contentItem: Item {

        RowLayout {
            id: row
            spacing: Kirigami.Units.smallSpacing
            anchors.centerIn: parent
            width: parent.width
            height: parent.height

            Item {
                Layout.minimumWidth: Kirigami.Units.gridUnit * 3.5
                Layout.minimumHeight: Kirigami.Units.gridUnit * 3.5
                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter

                Kirigami.Icon {
                    id: icon
                    source: "applications-all-symbolic"
                    anchors.fill: parent
                    anchors.margins: Kirigami.Units.smallSpacing
                    opacity: 0.8
                    color: Kirigami.Theme.highlightColor
                }

                Kirigami.Icon {
                    id: icon2
                    source: "view-media-favorite"
                    anchors.fill: parent
                    anchors.margins: Kirigami.Units.largeSpacing
                }
            }

            Label {
                id: label
                Layout.fillWidth: true
                text: i18n("Manage Favorites")
                color: Kirigami.Theme.textColor
                visible: favsIcon.activeFocus ? true : false
                verticalAlignment: Text.AlignVCenter
                wrapMode: Text.WordWrap
                fontSizeMode: Text.Fit
                font.pixelSize: 18
                minimumPixelSize: 12
                maximumLineCount: 2
            }
        }
    }

    onClicked: {
        favsManagerWindowView.showOverlay()
    }
}
