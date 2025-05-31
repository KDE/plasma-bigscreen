/*
    SPDX-FileCopyrightText: 2024 Aditya Mehra <aix.m@outlook.com>
    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami
import org.kde.bigscreen as Bigscreen

Control {
    id: delegate
    property var currentResolution
    property var currentRefreshRate
    property var currentModeId


    contentItem: GridLayout {
        id: localItem
        columns: 2
        uniformCellWidths: true
        uniformCellHeights: true
        property int cellWidth: width / 2

        Kirigami.ShadowedRectangle {
            Layout.preferredWidth: localItem.cellWidth
            Layout.fillHeight: true
            color: Kirigami.Theme.alternateBackgroundColor
            radius: 6
            shadow {
                size: Kirigami.Units.largeSpacing
            }

            PlasmaComponents.Label {
                anchors.fill: parent
                anchors.margins: Kirigami.Units.largeSpacing
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                color: Kirigami.Theme.textColor
                fontSizeMode: Text.Fit
                minimumPixelSize: 14
                font.pixelSize: 24
                text: i18n("Resolution: ") + delegate.currentResolution
            }
        }

        Kirigami.ShadowedRectangle {
            Layout.preferredWidth: localItem.cellWidth
            Layout.fillHeight: true
            color: Kirigami.Theme.alternateBackgroundColor
            radius: 6
            shadow {
                size: Kirigami.Units.largeSpacing
            }

            PlasmaComponents.Label {
                anchors.fill: parent
                anchors.margins: Kirigami.Units.largeSpacing
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                color: Kirigami.Theme.textColor
                fontSizeMode: Text.Fit
                minimumPixelSize: 14
                font.pixelSize: 24
                text: i18n("Refresh Rate: ") + delegate.currentRefreshRate
            }
        }

        Kirigami.ShadowedRectangle {
            Layout.preferredWidth: localItem.cellWidth
            Layout.fillHeight: true
            color: Kirigami.Theme.alternateBackgroundColor
            radius: 6
            shadow {
                size: Kirigami.Units.largeSpacing
            }

            PlasmaComponents.Label {
                anchors.fill: parent
                anchors.margins: Kirigami.Units.largeSpacing
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                color: Kirigami.Theme.textColor
                fontSizeMode: Text.Fit
                minimumPixelSize: 14
                font.pixelSize: 24
                text: i18n("Mode: ") + delegate.currentModeId
            }
        }
    }
}
