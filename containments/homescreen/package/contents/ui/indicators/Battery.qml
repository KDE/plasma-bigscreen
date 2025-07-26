// SPDX-FileCopyrightText: User8395 <therealuser8395@proton.me>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.bigscreen as Bigscreen
import org.kde.kirigami as Kirigami
import org.kde.plasma.private.battery

AbstractIndicator {
    id: batIcon
    icon.name: getIcon()
    visible: batteryControl.hasInternalBatteries
    text: i18n("Battery: %1%", batteryControl.percent)

    BatteryControlModel {
        id: batteryControl
    }

    function getIcon() {
        let icon = "battery-"

        if (batteryControl.percent < 10) {
            icon += "000"
        } else if (batteryControl.percent >= 10 && batteryControl.percent < 20) {
            icon += "010"
        } else if (batteryControl.percent >= 20 && batteryControl.percent < 30) {
            icon += "020"
        } else if (batteryControl.percent >= 30 && batteryControl.percent < 40) {
            icon += "030"
        } else if (batteryControl.percent >= 40 && batteryControl.percent < 50) {
            icon += "040"
        } else if (batteryControl.percent >= 50 && batteryControl.percent < 60) {
            icon += "050"
        } else if (batteryControl.percent >= 60 && batteryControl.percent < 70) {
            icon += "060"
        } else if (batteryControl.percent >= 70 && batteryControl.percent < 80) {
            icon += "070"
        } else if (batteryControl.percent >= 80 && batteryControl.percent < 90) {
            icon += "080"
        } else if (batteryControl.percent >= 90 && batteryControl.percent < 100) {
            icon += "090"
        } else if (batteryControl.percent == 100) {
            icon += "100"
        }

        if (batteryControl.pluggedIn) {
            icon += "-charging"
        }

        return icon
    }
}
