// SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import QtQuick.Templates as T
import QtQuick.Effects

import org.kde.kirigami as Kirigami

QQC2.TextField {
    id: root

    background: DelegateBackground {
        control: root
        neutralBackgroundColor: Kirigami.Theme.alternateBackgroundColor
    }

    topPadding: Kirigami.Units.gridUnit
    bottomPadding: Kirigami.Units.gridUnit
    leftPadding: Kirigami.Units.gridUnit
    rightPadding: Kirigami.Units.gridUnit

    font.pixelSize: 18
}