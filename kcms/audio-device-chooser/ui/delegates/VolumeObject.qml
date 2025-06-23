/*
    SPDX-FileCopyrightText: 2014-2015 Harald Sitter <sitter@kde.org>
    SPDX-FileCopyrightText: 2019 Sefa Eyeoglu <contact@scrumplex.net>
    SPDX-FileCopyrightText: 2019 Aditya Mehra <aix.m@outlook.com>
    SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>

    SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2

import org.kde.kirigami as Kirigami
import org.kde.bigscreen as Bigscreen
import org.kde.plasma.private.volume

Bigscreen.ItemDelegate {
    id: root
    property var model

    function increaseVal() {
        var l = 0
        l = slider.position + 0.05
        slider.value = slider.valueAt(l);
    }

    function decreaseVal() {
        var l = 0
        l = slider.position - 0.05
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

    contentItem: ColumnLayout {
        spacing: Kirigami.Units.smallSpacing

        QQC2.Label {
            id: label

            visible: text.length > 0
            Layout.fillWidth: true

            wrapMode: Text.WordWrap
            maximumLineCount: 1
            font.pixelSize: Bigscreen.Units.defaultFontPixelSize
            elide: Text.ElideRight
            color: Kirigami.Theme.textColor
            text: i18n("Adjust Volume")
        }

        RowLayout {
            Layout.fillWidth: true

            Kirigami.Icon {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredHeight: Kirigami.Units.iconSizes.medium
                Layout.preferredWidth: Kirigami.Units.iconSizes.medium
                source: "audio-card"
            }

            QQC2.Slider {
                id: slider
                Layout.alignment: Qt.AlignVCenter
                Layout.fillWidth: true

                // Helper properties to allow async slider updates.
                // While we are sliding we must not react to value updates
                // as otherwise we can easily end up in a loop where value
                // changes trigger volume changes trigger value changes.
                property int volume: model ? model.Volume : 0
                property bool ignoreValueChange: true

                from: model ? model.PulseAudio.MinimalVolume : 0
                to: model ? model.PulseAudio.NormalVolume : 0
                // TODO: implement a way to hide tickmarks
                // stepSize: to / (PulseAudio.MaximalVolume / PulseAudio.NormalVolume * 100.0)
                visible: !model || model.HasVolume
                enabled: model && model.VolumeWritable
                opacity: (!model || model.Muted) ? 0.5 : 1

                Component.onCompleted: {
                    ignoreValueChange = false;
                }

                onVolumeChanged: {
                    var oldIgnoreValueChange = ignoreValueChange;
                    ignoreValueChange = true;
                    value = model.Volume;
                    ignoreValueChange = oldIgnoreValueChange;
                }

                onValueChanged: {
                    if (model) {
                        model.Volume = value;
                    }
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

            QQC2.Label {
                id: percentLabel
                readonly property real value: (model && model.PulseObject.volume > slider.maximumValue) ? model.PulseObject.volume : slider.value

                Layout.preferredWidth: contentWidth + Kirigami.Units.largeSpacing
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                text: model ? i18nc("volume percentage", "%1%", Math.round(value / model.PulseAudio.NormalVolume * 100.0)) : ''
            }
        }
    }
}
