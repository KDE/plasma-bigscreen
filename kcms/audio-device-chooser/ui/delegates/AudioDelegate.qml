/*
    SPDX-FileCopyrightText: 2024 Aditya Mehra <aix.m@outlook.com>
    SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Controls as QQC2

import org.kde.kirigami as Kirigami
import org.kde.bigscreen as Bigscreen
import org.kde.plasma.private.volume

import "../code/icon.js" as Icon

Bigscreen.ButtonDelegate {
    id: delegate
    raisedBackground: false

    required property var model

    property string type
    readonly property bool isPlayback: type.substring(0, 4) == "sink"
    readonly property var currentPort: model.Ports[model.ActivePortIndex]

    icon.name: Icon.name(model.Volume, model.Muted, isPlayback ? "audio-volume" : "microphone-sensitivity")
    text: currentPort.description
    description: model.Description

    trailing: Kirigami.Icon {
        visible: model.PulseObject.default
        source: 'emblem-default-symbolic'
        implicitHeight: Kirigami.Units.iconSizes.medium
        implicitWidth: Kirigami.Units.iconSizes.medium
    }
}
