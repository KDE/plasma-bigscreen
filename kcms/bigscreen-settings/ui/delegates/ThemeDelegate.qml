/*
    SPDX-FileCopyrightText: 2019 Aditya Mehra <aix.m@outlook.com>
    SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami
import org.kde.bigscreen as BigScreen
import Qt5Compat.GraphicalEffects

BigScreen.AbstractDelegate {
    id: delegate
    implicitWidth: listView.cellWidth * 3.2
    implicitHeight: width

    Behavior on implicitWidth {
        NumberAnimation {
            duration: Kirigami.Units.longDuration
            easing.type: Easing.InOutQuad
        }
    }

    contentItem: Item {
        id: connectionItemLayout

        Image {
            id: preview
            anchors.fill: parent
            fillMode: Image.PreserveAspectFit
            source: Qt.resolvedUrl(model.previewPathRole)

            Rectangle {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: Kirigami.Units.gridUnit * 3
                color: Kirigami.Theme.backgroundColor
                opacity: 0.95

                PlasmaComponents.Label {
                    id: nameLabel
                    anchors.fill: parent
                    visible: text.length > 0
                    elide: Text.ElideRight
                    wrapMode: Text.WordWrap
                    maximumLineCount: 2
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    color: Kirigami.Theme.textColor
                    text: model.packageNameRole
                    font.pixelSize: height * 0.4
                }
            }
        }

        Kirigami.Icon {
            id: dIcon
            anchors.bottom: parent.bottom
            anchors.bottomMargin: -Kirigami.Units.smallSpacing
            anchors.right: parent.right
            anchors.rightMargin: -Kirigami.Units.smallSpacing
            width: Kirigami.Units.iconSizes.smallMedium
            height: width
            source: Qt.resolvedUrl("../images/green-tick-thick.svg")
            visible:  kcm.themeName === model.packageNameRole
        }
    }

    Keys.onReturnPressed: clicked()

    onClicked: {
        kcm.globalThemeListModel.setTheme(model.pluginIdRole)
    }
}
