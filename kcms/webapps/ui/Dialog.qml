// SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later OR LicenseRef-KDE-Accepted-LGPL

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import QtQuick.Effects

import org.kde.kirigami as Kirigami

QQC2.Dialog {
    id: root
    modal: true
    topPadding: Kirigami.Units.gridUnit + Kirigami.Units.largeSpacing
    bottomPadding: Kirigami.Units.gridUnit + Kirigami.Units.largeSpacing
    leftPadding: Kirigami.Units.gridUnit + Kirigami.Units.largeSpacing
    rightPadding: Kirigami.Units.gridUnit + Kirigami.Units.largeSpacing

    parent: Overlay.overlay

    width: Math.min(parent.width * 0.7, Math.max(parent.width * 0.4, Kirigami.Units.gridUnit * 35))

    Kirigami.Theme.inherit: false
    Kirigami.Theme.colorSet: Kirigami.Theme.Window

    background: Item {
        Rectangle {
            id: frame
            anchors.fill: parent
            color: Kirigami.Theme.backgroundColor
            radius: Kirigami.Units.largeSpacing

            Rectangle {
                id: footerBackground
                color: Kirigami.Theme.alternateBackgroundColor
                bottomLeftRadius: Kirigami.Theme.cornerRadius
                bottomRightRadius: Kirigami.Theme.cornerRadius
            }
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

    header: QQC2.Control {
        topPadding: Kirigami.Units.gridUnit + Kirigami.Units.largeSpacing
        bottomPadding: Kirigami.Units.gridUnit + Kirigami.Units.largeSpacing
        leftPadding: Kirigami.Units.gridUnit + Kirigami.Units.largeSpacing
        rightPadding: Kirigami.Units.gridUnit + Kirigami.Units.largeSpacing

        contentItem: Kirigami.Heading {
            text: root.title
            font.pixelSize: 32
            font.weight: Font.Light
        }
    }

    footer: QQC2.DialogButtonBox {
        topPadding: Kirigami.Units.gridUnit
        bottomPadding: Kirigami.Units.gridUnit
        leftPadding: Kirigami.Units.gridUnit
        rightPadding: Kirigami.Units.gridUnit

        standardButtons: QQC2.DialogButtonBox.Ok | QQC2.DialogButtonBox.Cancel
        onAccepted: root.accepted()
        onRejected: root.rejected()
    }
}