/*
    SPDX-FileCopyrightText: 2020 Aditya Mehra <aix.m@outlook.com>
    SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Controls
import org.kde.bigscreen as Bigscreen

Bigscreen.KCMAbstractDelegate {
    id: delegate
    property QtObject deviceObj: device
    itemIcon: model.iconName
    itemLabel: i18n(model.display)
    itemSubLabel: i18n(model.toolTip)
    itemTickVisible: false

    onClicked: {
        listView.currentIndex = index
        deviceConnectionView.forceActiveFocus()
    }
}