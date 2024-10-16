/*
    SPDX-FileCopyrightText: 2019 Aditya Mehra <Aix.m@outlook.com>
    SPDX-FileCopyrightText: 2014-2015 Harald Sitter <sitter@kde.org>

    SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL
*/

import QtQuick
import QtQuick.Layouts
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.private.volume
import org.kde.kirigami as Kirigami
import org.kde.plasma.private.nanoshell as NanoShell
import "code/icon.js" as Icon

AbstractIndicator {
    id: paIcon

    GlobalConfig {
        id: config
    }
    readonly property SinkModel paSinkModel: SinkModel { id: paSinkModel }
    property bool volumeFeedback: true
    property bool globalMute: config.globalMute
    property string displayName: i18n("Audio Volume")
    readonly property string dummyOutputName: "auto_null"
    icon.name: PreferredDevice.sink && !isDummyOutput(PreferredDevice.sink) ? AudioIcon.forVolume(volumePercent(PreferredDevice.sink.volume), PreferredDevice.sink.muted, "")
                                                                                          : AudioIcon.forVolume(0, true, "")
 
    function isDummyOutput(output) {
        return output && output.name === dummyOutputName;
    }

    function volumePercent(volume) {
        return Math.round(volume / PulseAudio.NormalVolume * 100.0);
    }

    function playFeedback(sinkIndex) {
        if (!volumeFeedback) {
            return;
        }
        if (sinkIndex == undefined) {
            sinkIndex = PreferredDevice.sink.index;
        }
        feedback.play(sinkIndex);
    }

    VolumeFeedback {
        id: feedback
    }

    onClicked: {
        configWindow.showOverlay("kcm_mediacenter_audiodevice")
    }
}
