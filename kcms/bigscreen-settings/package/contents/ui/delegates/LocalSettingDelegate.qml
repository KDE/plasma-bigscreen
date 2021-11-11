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
    property bool isChecked
    property alias name: textName.text
    property string customType

    highlighted: activeFocus

    onIsCheckedChanged: {
        setOption(customType, isChecked)
    }

    onFocusChanged: {
        if(focus){
            delegate.forceActiveFocus()
        }
    }

    Behavior on implicitWidth {
        NumberAnimation {
            duration: Kirigami.Units.longDuration
            easing.type: Easing.InOutQuad
        }
    }

    contentItem: RowLayout {
        id: localItem

        PlasmaComponents.Label {
            id: textName
            elide: Text.ElideRight
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            maximumLineCount: 2
            color: Kirigami.Theme.textColor
            textFormat: Text.PlainText
        }

        Kirigami.Icon {
            Layout.preferredWidth: PlasmaCore.Units.iconSizes.smallMedium
            Layout.preferredHeight: width
            enabled: isChecked
            opacity: enabled ? 1 : 0.25
            source: Qt.resolvedUrl("../images/green-tick-thick.svg")
        }
    }

    onClicked: {
        isChecked = !isChecked ? 1 : 0
    }
}
