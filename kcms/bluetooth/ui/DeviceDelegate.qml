/*
    SPDX-FileCopyrightText: 2019 Aditya Mehra <aix.m@outlook.com>
    SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.bigscreen as Bigscreen
import org.kde.bluezqt as BluezQt

import "script.js" as Script

Bigscreen.ButtonDelegate {
    id: delegate

    required property var model
    property bool connecting: false
    property bool disconnecting: false

    function desc() {
        if (connecting) {
            return "Connecting…";
        } else if (disconnecting) {
            return "Disconnecting…";
        } else {
            const labels = [];

            if (model.Connected) {
                labels.push(i18n("Connected"));
            }

            labels.push(Script.deviceTypeToString(model.Device));

            if (model.Battery) {
                labels.push(i18n("%1% Battery", model.Battery.percentage));
            }

            return labels.join(" · ");
        }
    }

    icon.name: model.Icon
    text: model.Name
    textFont.bold: model.Connected

    description: desc()
    onDescriptionChanged: desc()
}
