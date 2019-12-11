/*
    Copyright 2014-2015 Harald Sitter <sitter@kde.org>
    Copyright 2019 Sefa Eyeoglu <contact@scrumplex.net>
    Copyright 2019 Aditya Mehra <aix.m@outlook.com>

    This program is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public License as
    published by the Free Software Foundation; either version 2 of
    the License or (at your option) version 3 or any later version
    accepted by the membership of KDE e.V. (or its successor approved
    by the membership of KDE e.V.), which shall act as a proxy
    defined in Section 14 of version 3 of the license.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.9
import QtQuick.Layouts 1.3
import org.kde.plasma.core 2.1 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kirigami 2.10 as Kirigami
import org.kde.plasma.private.volume 0.1

ColumnLayout {
    //Layout.fillWidth: true
    //Layout.fillHeight: true
    //Layout.margins: Kirigami.Units.largeSpacing

    function increaseVal(){
        var l = 0
        l = slider.position + 0.1
        slider.value = slider.valueAt(l);

    }

    function decreaseVal(){
        var l = 0
        l = slider.position - 0.1
        slider.value = slider.valueAt(l);
    }

    SinkModel {
        id: paSinkModel
    }

    SourceModel {
        id: paSourceModel
    }

    Timer {
        id: updateTimer
        interval: 200
        onTriggered: slider.value = vol
    }

    PlasmaComponents.Label {
        id: label
        visible: text.length > 0
        Layout.fillWidth: true
        Layout.preferredHeight: Kirigami.Units.gridUnit * 1
        wrapMode: Text.WordWrap
        //horizontalAlignment: Text.AlignHCenter
        //verticalAlignment: Text.AlignVCenter
        maximumLineCount: 1
        elide: Text.ElideRight
        color: PlasmaCore.ColorScope.textColor
        text: "Volume"
    }

    RowLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true

        Kirigami.Icon {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredHeight: Kirigami.Units.iconSizes.medium
            Layout.preferredWidth: Layout.preferredHeight
            source: "audio-card"
        }

        PlasmaComponents.Slider {
            id: slider
            Layout.alignment: Qt.AlignVCenter
            // Helper properties to allow async slider updates.
            // While we are sliding we must not react to value updates
            // as otherwise we can easily end up in a loop where value
            // changes trigger volume changes trigger value changes.
            property int volume: Volume
            property bool ignoreValueChange: true
            Layout.fillWidth: true
            from: PulseAudio.MinimalVolume
            to: PulseAudio.NormalVolume
            // TODO: implement a way to hide tickmarks
            // stepSize: to / (PulseAudio.MaximalVolume / PulseAudio.NormalVolume * 100.0)
            visible: HasVolume
            enabled: VolumeWritable
            opacity: Muted ? 0.5 : 1

            Component.onCompleted: {
                ignoreValueChange = false;
            }

            onVolumeChanged: {
                var oldIgnoreValueChange = ignoreValueChange;
                ignoreValueChange = true;
                value = Volume;
                ignoreValueChange = oldIgnoreValueChange;
            }

            onValueChanged: {
                Volume = value;
            }

            onPressedChanged: {
                if (!pressed) {
                    // Make sure to sync the volume once the button was
                    // released.
                    // Otherwise it might be that the slider is at v10
                    // whereas PA rejected the volume change and is
                    // still at v15 (e.g.).
                    updateTimer.restart();
                }
            }
        }

        PlasmaComponents.Label {
            id: hundredPercentLabel
            Layout.preferredWidth: contentWidth + Kirigami.Units.largeSpacing
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            text: i18nd("kcm_pulseaudio", "100%")
        }
    }
}
