// SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import QtQuick.Templates as T
import QtQuick.Effects

import org.kde.kirigami as Kirigami
import org.kde.bigscreen as Bigscreen

T.Button {
    id: root

    Kirigami.Theme.colorSet: Kirigami.Theme.Button
    Kirigami.Theme.inherit: false

    implicitWidth: Math.max((text && display !== T.AbstractButton.IconOnly ?
        implicitBackgroundWidth : implicitHeight) + leftInset + rightInset,
        implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)

    Kirigami.MnemonicData.enabled: enabled && visible
    Kirigami.MnemonicData.controlType: Kirigami.MnemonicData.ActionElement
    Kirigami.MnemonicData.label: display !== T.AbstractButton.IconOnly ? text : ""
    Kirigami.MnemonicData.onActiveChanged: background?.updateItem()

    topPadding: Kirigami.Units.largeSpacing // Units.verticalPadding
    bottomPadding: Kirigami.Units.largeSpacing // Units.verticalPadding
    leftPadding: Units.horizontalPadding
    rightPadding: Units.horizontalPadding

    background: DelegateBackground { control: root }

    onPressed: root.forceActiveFocus()
    Keys.onReturnPressed: {
        clicked();
    }

    onActiveFocusChanged: {
        if (activeFocus) {
            Bigscreen.NavigationSoundEffects.playMovingSound();
        }
    }

    contentItem: RowLayout {
        spacing: 0

        Kirigami.Icon {
            Layout.rightMargin: Kirigami.Units.gridUnit
            Layout.alignment: Qt.AlignVCenter

            color: root.icon.color
            implicitHeight: (root.icon.name !== "") ? Kirigami.Units.iconSizes.medium : 0
            implicitWidth: (root.icon.name !== "") ? Kirigami.Units.iconSizes.medium : 0
            source: root.icon.name
            visible: root.icon.name != ''
        }

        QQC2.Label {
            id: internalTextItem
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            text: root.text
            font.pixelSize: Units.defaultFontPixelSize
            elide: Text.ElideRight
            visible: root.text
        }
    }
}