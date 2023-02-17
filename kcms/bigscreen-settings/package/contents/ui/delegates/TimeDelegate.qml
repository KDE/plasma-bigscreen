/*
    SPDX-FileCopyrightText: 2019 Aditya Mehra <aix.m@outlook.com>
    SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kirigami 2.19 as Kirigami
import org.kde.mycroft.bigscreen 1.0 as BigScreen
import Qt5Compat.GraphicalEffects

BigScreen.AbstractDelegate {
    id: delegate
    property alias name: labelItem.text

    highlighted: activeFocus

    Behavior on implicitWidth {
        NumberAnimation {
            duration: Kirigami.Units.longDuration
            easing.type: Easing.InOutQuad
        }
    }

    contentItem: Item {
        id: localItemLayout

        ColumnLayout {
            id: textLayout
            spacing: 0

            anchors {
                fill: parent
            }

            Kirigami.Icon {
                source: "preferences-system-time"
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: parent.width - labelItem.contentWidth
                Layout.preferredHeight: width
            }

            Label {
                id: labelItem
                Layout.alignment: Qt.AlignTop
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }

    Keys.onReturnPressed: (event)=> {
        clicked()
    }

    onClicked: (mouse)=> {
        deviceTimeSettingsArea.opened = true
        deviceTimeSettingsArea.forceActiveFocus()
    }
}
