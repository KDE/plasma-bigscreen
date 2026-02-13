// SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
// SPDX-FileCopyrightText: 2019 Aditya Mehra <aix.m@outlook.com>
// SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Window
import QtQuick.Controls as Controls

import org.kde.kirigami as Kirigami
import org.kde.bigscreen as Bigscreen

Controls.Button {
    id: kcmButton
    property var modelData: typeof model !== "undefined" ? model : null

    property string name
    property string iconName

    property bool selected

    width: settingsKCMMenu.width - settingsKCMMenu.leftMargin - settingsKCMMenu.rightMargin

    leftPadding: Kirigami.Units.gridUnit * 2
    rightPadding: Kirigami.Units.gridUnit * 2
    topPadding: Kirigami.Units.largeSpacing
    bottomPadding: Kirigami.Units.largeSpacing

    background: Bigscreen.DelegateBackground {
        id: kcmButtonBackground
        control: kcmButton

        raisedBackground: false
        translucentHighlight: true
        highlighted: kcmButton.selected
        borderHighlighted: highlighted || (kcmButton.ListView.isCurrentItem && settingsKCMMenu.activeFocus)

        // Only scale if this delegate is the shown KCM, and user focus is on it
        scale: (kcmButton.selected && kcmButton.ListView.isCurrentItem && settingsKCMMenu.activeFocus) ? 1.05 : 1
        Behavior on scale { NumberAnimation {} }
    }

    contentItem: RowLayout {
        id: kcmButtonLayout
        spacing: Kirigami.Units.gridUnit

        Kirigami.Icon {
            id: kcmButtonIcon
            source: kcmButton.iconName
            Layout.alignment: Qt.AlignLeft
            Layout.preferredHeight: Kirigami.Units.iconSizes.medium
            Layout.preferredWidth: kcmButtonIcon.height
        }

        Kirigami.Heading {
            id: kcmButtonLabel
            text: kcmButton.name
            wrapMode: Text.Wrap
            elide: Text.ElideRight
            font.weight: Font.Medium
            Layout.fillWidth: true
        }
    }
}
