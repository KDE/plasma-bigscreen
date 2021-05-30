/*
    SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2013-2017 Jan Grulich <jgrulich@redhat.com>

    SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL
*/

import QtQuick 2.14
import QtQuick.Layouts 1.14
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.networkmanagement 0.2 as PlasmaNM
import org.kde.kirigami 2.12 as Kirigami
import org.kde.plasma.private.nanoshell 2.0 as NanoShell

AbstractIndicator {
    id: connectionIcon

    icon.name: connectionIconProvider.connectionIcon

    PlasmaComponents.BusyIndicator {
        id: connectingIndicator

        anchors.fill: parent
        running: connectionIconProvider.connecting
        visible: running
    }

    PlasmaNM.NetworkStatus {
        id: networkStatus
    }

    PlasmaNM.NetworkModel {
        id: connectionModel
    }

    PlasmaNM.Handler {
        id: handler
    }

    PlasmaNM.ConnectionIcon {
        id: connectionIconProvider
    }
    onClicked: {
        NanoShell.StartupFeedback.open(
                            connectionIconProvider.connectionIcon,
                            i18n("Network"),
                            connectionIcon.Kirigami.ScenePosition.x + connectionIcon.width/2,
                            connectionIcon.Kirigami.ScenePosition.y + connectionIcon.height/2,
                            Math.min(connectionIcon.width, connectionIcon.height));
        plasmoid.nativeInterface.executeCommand("plasma-settings -s -m kcm_mediacenter_wifi")
    }
}
