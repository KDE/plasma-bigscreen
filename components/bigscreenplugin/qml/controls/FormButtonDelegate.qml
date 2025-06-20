// SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import QtQuick.Effects

import org.kde.kirigami as Kirigami

QQC2.ItemDelegate {
    id: root
    property string description

    topPadding: Kirigami.Units.gridUnit
    bottomPadding: Kirigami.Units.gridUnit
    leftPadding: Kirigami.Units.gridUnit
    rightPadding: Kirigami.Units.gridUnit

    background: FormDelegateBackground {
        control: root
    }

    onPressed: root.forceActiveFocus()

    Keys.onReturnPressed: {
        clicked();
    }

    contentItem: RowLayout {
        spacing: Kirigami.Units.largeSpacing

        Kirigami.Icon {
            Layout.alignment: Qt.AlignVCenter
            implicitHeight: Kirigami.Units.iconSizes.medium
            implicitWidth: Kirigami.Units.iconSizes.medium
            source: root.icon.name
            visible: root.icon.name
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: Kirigami.Units.smallSpacing

            QQC2.Label {
                Layout.fillWidth: true
                text: root.text
                font.pixelSize: 18
                elide: Text.ElideRight
            }
            QQC2.Label {
                Layout.fillWidth: true
                visible: text.length > 0
                text: root.description
                font.pixelSize: 18
                color: Kirigami.Theme.disabledTextColor
                elide: Text.ElideRight
            }
        }
    }
}