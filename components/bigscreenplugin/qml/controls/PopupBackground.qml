// SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import QtQuick.Effects

import org.kde.kirigami as Kirigami

Item {
    id: root

    Rectangle {
        id: frame
        anchors.fill: parent
        color: Kirigami.Theme.backgroundColor
        radius: Kirigami.Units.largeSpacing
    }

    MultiEffect {
        id: frameShadow

        anchors.fill: frame
        source: frame
        blurMax: 16
        shadowEnabled: true
        shadowOpacity: 0.6
        shadowColor: 'black'
    }
}