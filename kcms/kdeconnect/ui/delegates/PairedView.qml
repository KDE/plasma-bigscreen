/*
    SPDX-FileCopyrightText: 2020 Aditya Mehra <aix.m@outlook.com>
    SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>

    SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami
import org.kde.bigscreen as Bigscreen

Item {
    id: root
    Layout.fillWidth: true
    Layout.fillHeight: true

    signal unpairRequested()

    onActiveFocusChanged: {
        if (activeFocus) {
            unpairBtn.forceActiveFocus();
        }
    }

    ColumnLayout {
        spacing: Kirigami.Units.largeSpacing
        anchors.fill: parent

        Bigscreen.TextDelegate {
            text: i18n("This device is paired")
            icon.name: 'info'
            raisedBackground: false
        }

        Bigscreen.ButtonDelegate {
            id: unpairBtn
            onClicked: root.unpairRequested()
            text: i18n("Unpair")
            icon.name: 'network-disconnect'
        }

        Item { Layout.fillHeight: true }
    }
}
