// SPDX-FileCopyrightText: 2026 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2

import org.kde.kirigami as Kirigami
import org.kde.bigscreen as Bigscreen
import org.kde.plasma.plasmoid
import org.kde.plasma.networkmanagement as PlasmaNM
import org.kde.plasma.private.volume

RowLayout {
    id: actionsRow
    signal closeRequested()
    signal screenshotRequested()

    Layout.fillWidth: true
    Layout.bottomMargin: Kirigami.Units.largeSpacing

    onActiveFocusChanged: {
        if (activeFocus) {
            screenshotButton.forceActiveFocus();
        }
    }

    Item { Layout.fillWidth: true }

    Bigscreen.Button {
        id: screenshotButton
        flat: true
        icon.name: "view-fullscreen-symbolic"

        QQC2.ToolTip.visible: focus
        QQC2.ToolTip.text: i18n("Screenshot")
        KeyNavigation.right: audioButton

        onClicked: {
            actionsRow.screenshotRequested();
            actionsRow.closeRequested();
        }
    }

    Bigscreen.Button {
        id: audioButton
        flat: true

        QQC2.ToolTip.visible: focus
        QQC2.ToolTip.text: i18n("Audio")
        KeyNavigation.right: wifiButton

        readonly property string dummyOutputName: "auto_null"
        icon.name: PreferredDevice.sink
            && (!isDummyOutput(PreferredDevice.sink)
                ? AudioIcon.forVolume(volumePercent(PreferredDevice.sink.volume), PreferredDevice.sink.muted, "")
                : AudioIcon.forVolume(0, true, ""))

        function isDummyOutput(output) {
            return output && output.name === dummyOutputName;
        }

        function volumePercent(volume) {
            return Math.round(volume / PulseAudio.NormalVolume * 100.0);
        }

        onClicked: {
            Plasmoid.openSettings("kcm_mediacenter_audiodevice")
        }
    }

    Bigscreen.Button {
        id: wifiButton
        flat: true
        icon.name: connectionIconProvider.connectionIcon

        QQC2.ToolTip.visible: focus
        QQC2.ToolTip.text: i18n("Wi-Fi")
        KeyNavigation.right: shutdownButton
        onClicked: Plasmoid.openSettings("kcm_mediacenter_wifi")

        PlasmaNM.ConnectionIcon {
            id: connectionIconProvider
        }
    }

    Bigscreen.Button {
        id: shutdownButton
        flat: true
        icon.name: Bigscreen.Global.launchReason === "swap" ? "window-close" : "system-shutdown"

        QQC2.ToolTip.visible: focus
        QQC2.ToolTip.text: i18n("Shutdown")

        onClicked: (event)=> {
            if (Bigscreen.Global.launchReason === "swap") {
                Bigscreen.Global.swapSession();
            } else {
                // Prompt all since we don't have any other way of doing it.
                Bigscreen.Global.promptLogoutGreeter("promptAll");
            }
        }
    }

    Item { Layout.fillWidth: true }
}
