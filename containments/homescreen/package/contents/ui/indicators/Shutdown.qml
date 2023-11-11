/*
    SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2013-2017 Jan Grulich <jgrulich@redhat.com>

    SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL
*/

import QtQuick 2.14
import QtQuick.Layouts 1.14
import org.kde.plasma.plasma5support 2.0 as P5Support


AbstractIndicator {
    id: button

    icon.name: "system-shutdown"

    P5Support.DataSource {
        id: dataEngine
        engine: "powermanagement"
        connectedSources: ["PowerDevil"]
    }

    onClicked: {
        Plasmoid.requestShutdown();
    }
}
