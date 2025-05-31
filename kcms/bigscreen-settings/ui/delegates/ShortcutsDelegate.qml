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
import org.kde.kquickcontrols as KQuickControls
import Qt5Compat.GraphicalEffects

Bigscreen.AbstractDelegate {
    id: delegate
    property alias description: textDescription.text
    property string getActionPath
    property string setActionPath
    shadowSize: Kirigami.Units.largeSpacing

    highlighted: activeFocus
    
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
            id: textDescription
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
            id: shortcutLabel
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            text: kcm.getShortcut(getActionPath)
            color: Kirigami.Theme.textColor
            fontSizeMode: Text.Fit
            minimumPixelSize: 14
            font.pixelSize: 24
        }
    }

    Keys.onReturnPressed: clicked()

    onClicked: {
        settingsAreaLoader.setActionPath = setActionPath
        settingsAreaLoader.getActionPath = getActionPath
        settingsAreaLoader.currentShortcut = kcm.getShortcut(getActionPath)
        settingsAreaLoader.settingsAreaComponent = "delegates/ShortcutsPicker.qml"
        settingsAreaLoader.opened = true
    }
}
