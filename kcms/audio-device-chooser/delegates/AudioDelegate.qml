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
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kirigami 2.11 as Kirigami
import org.kde.plasma.private.volume 0.1

PlasmaComponents.ItemDelegate {
    id: delegate
    property bool isPlayback: type.substring(0, 4) == "sink"
    property bool onlyOne: false
    readonly property var currentPort: Ports[ActivePortIndex]
    property string type
    signal setDefault

    implicitWidth: listView.cellWidth
    implicitHeight: listView.height

    readonly property ListView listView: ListView.view

    z: listView.currentIndex == index ? 2 : 0
    onClicked: {
        PulseObject.default = true;
        listView.currentIndex = index
    }

    leftPadding: frame.margins.left + background.extraMargin
    topPadding: frame.margins.top + background.extraMargin
    rightPadding: frame.margins.right + background.extraMargin
    bottomPadding: frame.margins.bottom + background.extraMargin

    Keys.onReturnPressed: {
        clicked();
    }

    background: Item {
        id: background
        property real extraMargin:  Math.round(listView.currentIndex == index && delegate.activeFocus ? units.gridUnit/10 : units.gridUnit/2)
        Behavior on extraMargin {
            NumberAnimation {
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InOutQuad
            }
        }

        PlasmaCore.FrameSvgItem {
            anchors {
                fill: frame
                leftMargin: -margins.left
                topMargin: -margins.top
                rightMargin: -margins.right
                bottomMargin: -margins.bottom
            }
            imagePath: ":/delegates/background.svg"
            prefix: "shadow"
        }
        PlasmaCore.FrameSvgItem {
            id: frame
            anchors {
                fill: parent
                margins: background.extraMargin
            }
            imagePath: ":/delegates/background.svg"

            width: listView.currentIndex == index && delegate.activeFocus ? parent.width : parent.width - units.gridUnit
            height: listView.currentIndex == index && delegate.activeFocus ? parent.height : parent.height - units.gridUnit
            opacity: 0.8
        }
    }

    contentItem: ColumnLayout {
        spacing: 0

        PlasmaComponents.Label {
            id: label
            visible: text.length > 0

            Layout.fillWidth: true
            Layout.fillHeight: true
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            maximumLineCount: 2
            elide: Text.ElideRight
            color: PlasmaCore.ColorScope.textColor

            text: !currentPort ? Description : i18ndc("kcm_pulseaudio", "label of device items", "%1 (%2)", currentPort.description, Description)
        }

        Kirigami.Separator {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Kirigami.Theme.textColor
            visible: PulseObject.default ? 1 : 0
        }

        Kirigami.Icon {
            id: icon
            Layout.preferredWidth: Kirigami.Units.iconSizes.large
            Layout.preferredHeight: Kirigami.Units.iconSizes.large
            Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom
            source: "answer-correct"
            visible: PulseObject.default ? 1 : 0
        }
    }
}
