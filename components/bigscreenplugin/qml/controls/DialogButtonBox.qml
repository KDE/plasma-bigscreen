// SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later OR LicenseRef-KDE-Accepted-GPL

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import QtQuick.Effects

import org.kde.kirigami as Kirigami

QQC2.DialogButtonBox {
    id: root

    required property var dialog

    visible: count > 0

    topPadding: Kirigami.Units.gridUnit
    bottomPadding: Kirigami.Units.gridUnit
    leftPadding: Kirigami.Units.gridUnit
    rightPadding: Kirigami.Units.gridUnit
    alignment: Qt.AlignRight

    spacing: Kirigami.Units.mediumSpacing
    position: QQC2.DialogButtonBox.Footer

    standardButtons: root.dialog.standardButtons
    onAccepted: root.dialog.accept()
    onRejected: root.dialog.reject()
    onApplied: root.dialog.applied()
    onDiscarded: root.dialog.discarded()
    onHelpRequested: root.dialog.helpRequested()
    onReset: root.dialog.reset()

    onActiveFocusChanged: {
        if (activeFocus) {
            listView.currentIndex = 0;
            listView.forceActiveFocus();
        }
    }

    delegate: Button {
        // HACK: for some reason the height isn't correct on initial start
        onImplicitHeightChanged: height = implicitHeight

        onActiveFocusChanged: {
            if (activeFocus) {
                listView.forceActiveFocus()
            }
        }
        Kirigami.MnemonicData.controlType: Kirigami.MnemonicData.DialogButton
    }

    contentItem: ListView {
        id: listView
        keyNavigationEnabled: true
        implicitWidth: contentWidth
        implicitHeight: buttonMetrics.implicitHeight

        model: root.contentModel
        spacing: root.spacing
        orientation: ListView.Horizontal
        boundsBehavior: Flickable.StopAtBounds
        snapMode: ListView.SnapToItem
        delegate: root.delegate

        Button {
            id: buttonMetrics
            visible: false
            text: 'A'
            icon.name: 'dialog-ok'
        }

        Keys.onLeftPressed: {
            if (currentIndex > 0) {
                currentIndex = Math.max(0, currentIndex - 1);
            }
        }

        Keys.onRightPressed: {
            if (currentIndex < count - 1) {
                currentIndex = Math.min(count - 1, currentIndex + 1);
            }
        }
    }
}