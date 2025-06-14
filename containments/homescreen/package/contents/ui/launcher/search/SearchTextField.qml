// SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import QtQuick.Controls as QQC2

import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.private.nanoshell as NanoShell

import org.kde.kirigami as Kirigami

PlasmaComponents.TextField {
    id: root
    background: Item {}

    leftPadding: Kirigami.Units.gridUnit + searchIcon.anchors.leftMargin + searchIcon.width
    rightPadding: Kirigami.Units.gridUnit
    topPadding: Kirigami.Units.gridUnit * 2
    bottomPadding: Kirigami.Units.gridUnit

    placeholderText: i18nc("@info:placeholder", "Search…")
    inputMethodHints: Qt.ImhNoPredictiveText // don't need to press "enter" to update text

    font.weight: Font.Light
    font.pixelSize: 32

    Kirigami.Icon {
        id: searchIcon
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: Math.round((parent.topPadding - parent.bottomPadding) / 2)

        implicitHeight: Kirigami.Units.iconSizes.medium
        implicitWidth: Kirigami.Units.iconSizes.medium
        color: Kirigami.Theme.textColor

        source: "search"
    }
}