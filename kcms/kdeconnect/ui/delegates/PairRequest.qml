/*
    SPDX-FileCopyrightText: 2019 Aditya Mehra <aix.m@outlook.com>
    SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>

    SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import org.kde.bigscreen as Bigscreen
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami
import org.kde.kdeconnect

Item {
    id: root
    Layout.fillWidth: true
    Layout.fillHeight: true

    signal acceptPairingRequested()
    signal rejectPairingRequested()

    onActiveFocusChanged: {
        if (activeFocus) {
            acceptBtn.forceActiveFocus();
        }
    }

    ColumnLayout {
        anchors.fill: parent

        Bigscreen.TextDelegate {
            text: i18n("This device is requesting to be paired")
        }

        Bigscreen.ButtonDelegate {
            id: acceptBtn
            onClicked: root.acceptPairingRequested()
            KeyNavigation.down: rejectBtn

            icon.name: "dialog-ok"
            text: i18n("Accept")
        }

        Bigscreen.ButtonDelegate {
            id: rejectBtn
            KeyNavigation.up: acceptBtn
            onClicked: root.rejectPairingRequested()

            icon.name: "dialog-cancel"
            text: i18n("Reject")
        }

        Item { Layout.fillHeight: true }
    }
}
