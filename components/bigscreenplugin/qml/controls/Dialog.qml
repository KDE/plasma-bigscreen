// SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later OR LicenseRef-KDE-Accepted-GPL

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import QtQuick.Effects

import org.kde.kirigami as Kirigami

QQC2.Dialog {
    id: root

    /*!
       \brief This property holds item to focus when the dialog opens.
       \default footer
     */
    property var openFocusItem: footer

    modal: true

    topPadding: Kirigami.Units.gridUnit + Kirigami.Units.largeSpacing
    bottomPadding: Kirigami.Units.gridUnit + Kirigami.Units.largeSpacing
    leftPadding: Kirigami.Units.gridUnit + Kirigami.Units.largeSpacing
    rightPadding: Kirigami.Units.gridUnit + Kirigami.Units.largeSpacing

    width: Math.min(parent.width * 0.7, Math.max(parent.width * 0.4, Kirigami.Units.gridUnit * 35))
    parent: QQC2.Overlay.overlay
    anchors.centerIn: parent

    standardButtons: QQC2.Dialog.NoButton

    onOpened: openFocusItem.forceActiveFocus()
    onRejected: root.close()

    background: PopupBackground {}

    header: QQC2.Control {
        topPadding: Kirigami.Units.gridUnit
        bottomPadding: Kirigami.Units.gridUnit
        leftPadding: Kirigami.Units.gridUnit
        rightPadding: Kirigami.Units.gridUnit

        contentItem: Kirigami.Heading {
            text: root.title
            font.pixelSize: 28
            font.weight: Font.Light
            wrapMode: Text.Wrap
        }
    }

    footer: DialogButtonBox {
        dialog: root
    }
}