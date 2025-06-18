/*
    SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2013-2017 Jan Grulich <jgrulich@redhat.com>
    SPDX-FileCopyrightText: 2025 Seshan Ravikumar <seshan@sineware.ca>
    SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL
*/

import QtQuick
import QtQuick.Layouts
import org.kde.bigscreen as Bigscreen

AbstractIndicator {
    id: button
    icon.name: Bigscreen.Global.launchReason === "swap" ? "window-close" : "system-shutdown"
    text: (Bigscreen.Global.launchReason === "swap") ? i18n('Exit Bigscreen') : i18n('Power')

    onClicked: (event)=> {
        if (Bigscreen.Global.launchReason === "swap") {
            Bigscreen.Global.swapSession();
        } else {
            // Prompt all since we don't have any other way of doing it.
            Bigscreen.Global.promptLogoutGreeter("promptAll");
        }
    }
}
