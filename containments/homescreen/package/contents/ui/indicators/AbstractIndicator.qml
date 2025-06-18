/*
    SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2013-2017 Jan Grulich <jgrulich@redhat.com>
    SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>

    SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2

import org.kde.plasma.components as PlasmaComponents
import org.kde.bigscreen as Bigscreen
import org.kde.kirigami as Kirigami
import org.kde.ksvg as KSvg

PlasmaComponents.ToolButton {
    id: button

    Kirigami.Theme.inherit: false
    Kirigami.Theme.colorSet: Kirigami.Theme.Complementary

    Layout.preferredWidth: height

    leftPadding: Kirigami.Units.smallSpacing
    topPadding: Kirigami.Units.smallSpacing
    rightPadding: Kirigami.Units.smallSpacing
    bottomPadding: Kirigami.Units.smallSpacing

    background: Rectangle {
        color: (button.focus) ?
                Qt.rgba(Kirigami.Theme.highlightColor.r, Kirigami.Theme.highlightColor.g, Kirigami.Theme.highlightColor.b, 0.2) : 'transparent'
        radius: Kirigami.Units.cornerRadius

        Kirigami.Theme.inherit: false
        Kirigami.Theme.colorSet: Kirigami.Theme.Button

        border.width: 2
        border.color: (button.focus) ? Kirigami.Theme.highlightColor : 'transparent'
    }

    QQC2.ToolTip.visible: text && focus
    QQC2.ToolTip.text: text

    contentItem: Kirigami.Icon {
        id: icon
        source: button.icon.name
    }

    Keys.onReturnPressed: (event)=> {
        clicked();
    }

    onClicked: (event)=> {
        Bigscreen.NavigationSoundEffects.playClickedSound()
    }

    Keys.onPressed: (event)=> {
        switch (event.key) {
            case Qt.Key_Down:
            case Qt.Key_Right:
            case Qt.Key_Left:
            case Qt.Key_Tab:
            case Qt.Key_Backtab:
                Bigscreen.NavigationSoundEffects.playMovingSound();
                break;
            default:
                break;
        }
    }
}
