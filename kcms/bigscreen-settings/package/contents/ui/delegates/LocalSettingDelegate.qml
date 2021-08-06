/*
    SPDX-FileCopyrightText: 2019 Aditya Mehra <aix.m@outlook.com>
    SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.14
import QtQuick.Layouts 1.14
import QtQuick.Controls 2.14
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents2
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kirigami 2.12 as Kirigami
import org.kde.mycroft.bigscreen 1.0 as BigScreen
import QtGraphicalEffects 1.14

BigScreen.AbstractDelegate {
    id: delegate
    property alias isChecked: radioItem.checked
    property alias name: radioItem.text
    property string customType

    highlighted: activeFocus

    Behavior on implicitWidth {
        NumberAnimation {
            duration: Kirigami.Units.longDuration
            easing.type: Easing.InOutQuad
        }
    }

    contentItem: Item {
        id: localItemLayout

        RadioDelegate {
            id: radioItem

            anchors {
                fill: parent
                leftMargin: Kirigami.Units.smallSpacing
            }

            onCheckedChanged: {
                setOption(customType, checked)
            }
        }
    }

    Keys.onReturnPressed: clicked()

    onClicked: {
        if(radioItem.checked){
            radioItem.checked = false;
        } else {
            radioItem.checked = true;
        }
    }
}
