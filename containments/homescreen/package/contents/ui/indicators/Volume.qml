/*
    Copyright 2019 Aditya Mehra <Aix.m@outlook.com>
    Copyright 2014-2015 Harald Sitter <sitter@kde.org>

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) version 3, or any
    later version accepted by the membership of KDE e.V. (or its
    successor approved by the membership of KDE e.V.), which shall
    act as a proxy defined in Section 6 of version 3 of the license.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with this library.  If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.2
import QtQuick.Layouts 1.4
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.private.volume 0.1
import "code/icon.js" as Icon

AbstractIndicator {

    id: paIcon
    property bool volumeFeedback: true
    property int maxVolumeValue: Math.round(100 * PulseAudio.NormalVolume / 100.0)
    property int volumeStep: Math.round(5 * PulseAudio.NormalVolume / 100.0)
    readonly property string dummyOutputName: "auto_null"
    icon.name: paSinkModel.preferredSink && !isDummyOutput(paSinkModel.preferredSink) ? Icon.name(paSinkModel.preferredSink.volume, paSinkModel.preferredSink.muted)
                                                                                      : Icon.name(0, true)

    function isDummyOutput(output) {
        return output && output.name === dummyOutputName;
    }

    function boundVolume(volume) {
        return Math.max(PulseAudio.MinimalVolume, Math.min(volume, maxVolumeValue));
    }

    function volumePercent(volume, max){
        if(!max) {
            max = PulseAudio.NormalVolume;
        }
        return Math.round(volume / max * 100.0);
    }

    function playFeedback(sinkIndex) {
        if(!volumeFeedback){
            return;
        }
        if(sinkIndex == undefined) {
            sinkIndex = paSinkModel.preferredSink.index;
        }
        feedback.play(sinkIndex)
    }

    function increaseVolume() {
        if (!paSinkModel.preferredSink || isDummyOutput(paSinkModel.preferredSink)) {
            return;
        }

        var volume = boundVolume(paSinkModel.preferredSink.volume + volumeStep);
        var percent = volumePercent(volume, maxVolumeValue);
        paSinkModel.preferredSink.muted = percent == 0;
        paSinkModel.preferredSink.volume = volume;
        osd.show(percent);
        playFeedback();

    }

    function decreaseVolume() {
        if (!paSinkModel.preferredSink || isDummyOutput(paSinkModel.preferredSink)) {
            return;
        }

        var volume = boundVolume(paSinkModel.preferredSink.volume - volumeStep);
        var percent = volumePercent(volume, maxVolumeValue);
        paSinkModel.preferredSink.muted = percent == 0;
        paSinkModel.preferredSink.volume = volume;
        osd.show(percent);
        playFeedback();
    }



    function muteVolume() {
        if (!paSinkModel.preferredSink || isDummyOutput(paSinkModel.preferredSink)) {
            return;
        }

        var toMute = !paSinkModel.preferredSink.muted;
        paSinkModel.preferredSink.muted = toMute;
        osd.show(toMute ? 0 : volumePercent(paSinkModel.preferredSink.volume, maxVolumeValue));
        if (!toMute) {
            playFeedback();
        }
    }

    SinkModel {
        id: paSinkModel
    }

    VolumeOSD {
        id: osd
    }

    VolumeFeedback {
        id: feedback
    }

    GlobalActionCollection {
        // KGlobalAccel cannot transition from kmix to something else, so if
        // the user had a custom shortcut set for kmix those would get lost.
        // To avoid this we hijack kmix name and actions. Entirely mental but
        // best we can do to not cause annoyance for the user.
        // The display name actually is updated to whatever registered last
        // though, so as far as user visible strings go we should be fine.
        // As of 2015-07-21:
        //   componentName: kmix
        //   actions: increase_volume, decrease_volume, mute
        name: "kmix"
        displayName: main.displayName

        GlobalAction {
            objectName: "increase_volume"
            text: i18n("Increase Volume")
            shortcut: Qt.Key_VolumeUp
            onTriggered: increaseVolume()
        }

        GlobalAction {
            objectName: "decrease_volume"
            text: i18n("Decrease Volume")
            shortcut: Qt.Key_VolumeDown
            onTriggered: decreaseVolume()
        }

        GlobalAction {
            objectName: "mute"
            text: i18n("Mute")
            shortcut: Qt.Key_VolumeMute
            onTriggered: muteVolume()
        }

    }

    onClicked: {
        feedbackWindow.open(i18n("Audio Device chooser"), "headphone");
        plasmoid.nativeInterface.executeCommand("plasma-settings -s -m kcm_audiodevice")
    }
}
