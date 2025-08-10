/*
    SPDX-FileCopyrightText: 2020 Aditya Mehra <aix.m@outlook.com>
    SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>

    SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL

*/

import QtQuick.Layouts
import QtQuick
import QtQuick.Window
import QtQuick.Controls as QQC2

import org.kde.kirigami as Kirigami
import org.kde.kdeconnect
import org.kde.kcmutils as KCM
import org.kde.bigscreen as Bigscreen

import "delegates" as Delegates

KCM.SimpleKCM {
    id: root

    title: i18n("KDE Connect")
    background: null

    leftPadding: Kirigami.Units.smallSpacing
    topPadding: Kirigami.Units.smallSpacing
    rightPadding: Kirigami.Units.smallSpacing
    bottomPadding: Kirigami.Units.smallSpacing

    Component.onCompleted: {
        connectionView.forceActiveFocus();
    }

    DevicesModel {
        id: allDevicesModel
    }

    contentItem: ColumnLayout {
        spacing: 0

        QQC2.Label {
            text: i18n("Devices")
            font.pixelSize: 22
            font.weight: Font.Normal
            Layout.topMargin: Kirigami.Units.gridUnit
            Layout.bottomMargin: Kirigami.Units.gridUnit
        }

        ListView {
            id: connectionView
            model: allDevicesModel
            clip: true
            spacing: Kirigami.Units.smallSpacing

            Layout.fillWidth: true
            Layout.fillHeight: true

            delegate: Delegates.DeviceDelegate {
                width: connectionView.width
                onClicked: {
                    deviceConnectionView.currentDevice = deviceObj;
                    deviceConnectionView.open();
                }
            }
        }

        DeviceConnectionSidebar {
            id: deviceConnectionView
        }
    }
}
