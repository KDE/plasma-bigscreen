/*
    SPDX-FileCopyrightText: 2020 Aditya Mehra <aix.m@outlook.com>
    SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>

    SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import org.kde.bigscreen as Bigscreen
import org.kde.kirigami as Kirigami

Item {
    id: notReachableDevice
    Layout.fillWidth: true
    Layout.fillHeight: true

    ColumnLayout {
        anchors.fill: parent

        Bigscreen.TextDelegate {
            icon.name: 'info'
            text: i18n("This device is not reachable")
            raisedBackground: false
        }
        Item { Layout.fillHeight: true }
    }
}
