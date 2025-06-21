// SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later OR LicenseRef-KDE-Accepted-GPL

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

    width: Math.min(parent.width * 0.7, Math.max(parent.width * 0.4, Kirigami.Units.gridUnit * 35))
    parent: QQC2.Overlay.overlay
    anchors.centerIn: parent

    onRejected: root.close()

    background: Item {
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

    header: QQC2.Control {
        topPadding: Kirigami.Units.gridUnit
        bottomPadding: Kirigami.Units.gridUnit
        leftPadding: Kirigami.Units.gridUnit
        rightPadding: Kirigami.Units.gridUnit

        contentItem: Kirigami.Heading {
            text: root.title
            font.pixelSize: 28
            font.weight: Font.Light
        }
    }

    footer: QQC2.Control {
        id: footerControl
        Layout.fillWidth: true

        background: Rectangle {
            color: Kirigami.Theme.alternateBackgroundColor
            bottomLeftRadius: Kirigami.Units.largeSpacing
            bottomRightRadius: Kirigami.Units.largeSpacing
        }

        contentItem: QQC2.DialogButtonBox {
            topPadding: Kirigami.Units.gridUnit
            bottomPadding: Kirigami.Units.gridUnit
            leftPadding: Kirigami.Units.gridUnit
            rightPadding: Kirigami.Units.gridUnit

            standardButtons: QQC2.DialogButtonBox.Ok | QQC2.DialogButtonBox.Cancel
            onAccepted: root.accepted()
            onRejected: root.rejected()
        }
    }
}