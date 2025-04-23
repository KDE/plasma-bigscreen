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
import org.kde.plasma.components as PlasmaComponents

Item {
    id: root
    Layout.fillWidth: true
    Layout.fillHeight: true

    signal pairingRequested()

    onActiveFocusChanged: {
        if (activeFocus) {
            pairBtn.forceActiveFocus()
        }
    }

    Timer {
        id: timer
    }

    function delay(delayTime, cb) {
        timer.interval = delayTime;
        timer.repeat = false;
        timer.triggered.connect(cb);
        timer.start();
    }

    ColumnLayout {
        anchors.fill: parent

        Bigscreen.TextDelegate {
            id: unpairedLabel
            icon.name: 'info'
            text: i18n("This device is not paired")
            raisedBackground: false
        }

        Bigscreen.ButtonDelegate {
            id: pairBtn

            onClicked: {
                root.pairingRequested();
                unpairedLabel.text = i18n("Pairing request sent")
            }

            icon.name: "network-connect"
            text: i18n("Pair")
        }

        Item { Layout.fillHeight: true }
    }
}
