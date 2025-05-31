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
import org.kde.bigscreen as Bigscreen
import Qt5Compat.GraphicalEffects

Bigscreen.AbstractDelegate {
    id: delegate
    property bool isChecked
    property alias name: textLabel.text
    property alias description: descriptionLabel.text
    property string customType
    Layout.preferredHeight: Kirigami.Units.gridUnit * 4.5
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

        ColumnLayout {
            id: textLayout
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: Kirigami.Units.largeSpacing
            anchors.rightMargin: Kirigami.Units.largeSpacing
        
            PlasmaComponents.Label {
                id: textLabel
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

            PlasmaComponents.Label {
                id: descriptionLabel
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                color: Kirigami.Theme.disabledTextColor
                fontSizeMode: Text.Fit
                minimumPixelSize: 14
                font.pixelSize: 20
            }
        
        }
              
        Switch {
            scale: delegate.size
            checked: isChecked
            onClicked: {
                isChecked = !isChecked ? 1 : 0
            }
        }
    }

    onClicked: {
        isChecked = !isChecked ? 1 : 0
    }
}
