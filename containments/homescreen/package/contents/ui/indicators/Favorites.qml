/*
    SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2019 Aditya Mehra <aix.m@outlook.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.bigscreen as Bigscreen
import org.kde.kirigami as Kirigami

AbstractIndicator {
    id: favsIcon
    icon.name: "edit-entry"

    onClicked: {
        favsManagerWindowView.showOverlay()
    }
}
