/*
    SPDX-FileCopyrightText: 2024 Aditya Mehra <aix.m@outlook.com>
    SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Controls
import org.kde.kirigami as Kirigami
import org.kde.bigscreen as Bigscreen
import org.kde.plasma.private.volume
import "../code/icon.js" as Icon

Bigscreen.KCMAbstractDelegate {
    id: delegate
    property bool isPlayback: type.substring(0, 4) == "sink"
    property bool onlyOne: false
    readonly property var currentPort: Ports[ActivePortIndex]
    property string type
    property bool isDefaultDevice: deviceDefaultIcon.visible
    signal setDefault

    property var hasVolume: HasVolume
    property bool volumeWritable: VolumeWritable
    property var muted: Muted
    property var vol: Volume
    property var pObject: PulseObject
    property int focusMarginWidth: listView.currentIndex == index && delegate.activeFocus ? contentLayout.width : contentLayout.width - Kirigami.Units.gridUnit
    
    itemIcon: Icon.name(Volume, Muted, isPlayback ? "audio-volume" : "microphone-sensitivity")
    itemLabel: currentPort.description
    itemSubLabel: Description
    itemTickSource: Qt.resolvedUrl("../images/green-tick-thick.svg")
    itemTickOpacity: model.PulseObject.default ? 1 : 0

    onClicked: {
        listView.currentIndex = index
        settingsViewDetails.currentItem.forceActiveFocus()
    }
}
