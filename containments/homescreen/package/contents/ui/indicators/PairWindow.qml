/*
    SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2019 Aditya Mehra <aix.m@outlook.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls as QQC2

import org.kde.kdeconnect as KDEConnect
import org.kde.kirigami as Kirigami
import org.kde.bigscreen as Bigscreen

Window {
    id: root
    property QtObject currentDevice
    property bool pairingRequest: currentDevice.isPairRequestedByPeer ? 1 : 0
    color: 'transparent'
    flags: Qt.WindowStaysOnTopHint | Qt.FramelessWindowHint

    onClosing: {
        if (pairingRequest) {
            currentDevice.cancelPairing()
        }
    }

    onVisibleChanged: {
        if (visible) {
            dialog.open();
            showMaximized();
            acceptButton.forceActiveFocus();
        }
    }

    Bigscreen.Dialog {
        id: dialog
        title: i18n("Accept Pairing Request From %1?", currentDevice.name)
        standardButtons: Bigscreen.Dialog.Yes | Bigscreen.Dialog.Cancel

        onAccepted: {
            currentDevice.acceptPairing()
            pairingRequest = false
            root.close()
        }
        onRejected: {
            currentDevice.cancelPairing()
            pairingRequest = false
            root.close()
        }
    }
}
