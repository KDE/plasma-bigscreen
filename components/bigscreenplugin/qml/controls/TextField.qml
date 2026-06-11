// SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import QtQuick.Templates as T
import QtQuick.Effects

import org.kde.kirigami as Kirigami
import org.kde.bigscreen as Bigscreen

QQC2.TextField {
    id: root

    background: DelegateBackground {
        control: root
        alternateBackgroundColor: true
    }

    topPadding: Kirigami.Units.gridUnit
    bottomPadding: Kirigami.Units.gridUnit
    leftPadding: Kirigami.Units.gridUnit
    rightPadding: Kirigami.Units.gridUnit

    font.pixelSize: 18

    onActiveFocusChanged: {
        if (activeFocus) {
            Bigscreen.NavigationSoundEffects.playMovingSound();
        }
    }
}
