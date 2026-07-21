/*
    SPDX-FileCopyrightText: [Year] [Your Name/Email]
    SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL
*/

import QtQuick
import QtQuick.Layouts
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami
import org.kde.bluezqt as BluezQt // Replaces PlasmaNM
import org.kde.plasma.private.nanoshell as NanoShell
import org.kde.plasma.plasmoid

AbstractIndicator {
    id: bluetoothIcon
    text: i18n("Bluetooth Settings")

    icon.name: {
        if (!BluezQt.Manager.operational) {
            return "network-bluetooth-inactive"
        }
        return "network-bluetooth"
    }

    PlasmaComponents.BusyIndicator {
        id: connectingIndicator
        anchors.fill: parent

        running: false 
        visible: running
    }

    onClicked: {
        Plasmoid.openSettings("kcm_mediacenter_bluetooth")
    }
}