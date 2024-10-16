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
    property alias name: labelItem.text

    highlighted: activeFocus

    Behavior on implicitWidth {
        NumberAnimation {
            duration: Kirigami.Units.longDuration
            easing.type: Easing.InOutQuad
        }
    }

    contentItem: RowLayout {
        id: localItem
        anchors.fill: parent
        anchors.margins: Kirigami.Units.largeSpacing

        Kirigami.Icon {
            Layout.fillHeight: true
            Layout.preferredWidth: height
            Layout.alignment: Qt.AlignLeft
            opacity: enabled ? 1 : 0.25
            source: "preferences-system-time"
        }

        PlasmaComponents.Label {
            id: labelItem
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
            elide: Text.ElideRight
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            color: Kirigami.Theme.textColor
            textFormat: Text.PlainText
            fontSizeMode: Text.Fit
            minimumPixelSize: 14
            font.pixelSize: 24
        }
    }

    Keys.onReturnPressed: clicked()

    onClicked: {
        settingsAreaLoader.opened = true
        settingsAreaLoader.settingsAreaComponent = "delegates/DeviceTimeSettings.qml"
    }
}
