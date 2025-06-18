/*
    SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2013-2017 Jan Grulich <jgrulich@redhat.com>

    SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL
*/

import QtQuick
import QtQuick.Layouts
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.networkmanagement as PlasmaNM
import org.kde.kirigami as Kirigami
import org.kde.plasma.private.nanoshell as NanoShell

AbstractIndicator {
    id: connectionIcon
    text: i18n('Internet Settings')

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
        configWindow.showOverlay("kcm_mediacenter_wifi")
    }
}
