/*
    SPDX-FileCopyrightText: 2020 Aditya Mehra <aix.m@outlook.com>

    SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL

*/

import QtQuick.Layouts
import QtQuick
import QtQuick.Window
import QtQuick.Controls
import org.kde.plasma.components as PlasmaComponents3
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import org.kde.bigscreen as Bigscreen
import org.kde.plasma.private.batterymonitor

Item {
    id: powerManagementItem
    property bool inhibit

    onInhibitChanged: {
        if (inhibit) {
            const reason = i18nc("@info", "Plasma Bigscreen has enabled system-wide inhibition");
            inhibitionControl.inhibit(reason);
        } else {
            inhibitionControl.uninhibit();
        }
    }

    InhibitionControl {
        id: inhibitionControl
        isSilent: false
    }
}
