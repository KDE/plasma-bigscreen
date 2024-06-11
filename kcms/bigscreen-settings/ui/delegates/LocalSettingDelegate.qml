/*
    SPDX-FileCopyrightText: 2019 Aditya Mehra <aix.m@outlook.com>
    SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.14
import QtQuick.Layouts 1.14
import QtQuick.Controls 2.14
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kirigami as Kirigami
import org.kde.bigscreen 1.0 as BigScreen
import Qt5Compat.GraphicalEffects

BigScreen.AbstractDelegate {
    id: delegate
    property bool isChecked
    property alias name: textName.text
    property string customType
    shadowSize: Kirigami.Units.largeSpacing

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
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            color: Kirigami.Theme.textColor
            fontSizeMode: Text.Fit
            minimumPixelSize: 14
            font.pixelSize: 24
        }

        Kirigami.Icon {
            Layout.fillHeight: true
            Layout.preferredWidth: height
            enabled: isChecked
            opacity: enabled ? 1 : 0.25
            source: Qt.resolvedUrl("../images/green-tick-thick.svg")
        }
    }

    onClicked: {
        isChecked = !isChecked ? 1 : 0
    }
}
