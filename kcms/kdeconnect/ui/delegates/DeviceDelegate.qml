/*
    SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2020 Aditya Mehra <aix.m@outlook.com>
    SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Controls

import org.kde.bigscreen as Bigscreen

Bigscreen.ButtonDelegate {
    id: delegate
    raisedBackground: false

    property QtObject deviceObj: model.device

    icon.name: model.iconName
    text: i18n(model.name)
    description: i18n(model.toolTip)
}