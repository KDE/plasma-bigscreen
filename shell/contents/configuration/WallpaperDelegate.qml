/*
    SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.12
import org.kde.plasma.core 2.0 as PlasmaCore

import org.kde.kirigami 2.11 as Kirigami
import org.kde.mycroft.bigscreen 1.0 as BigScreen

BigScreen.AbstractDelegate {
    id: delegate
    width: wallpapersView.cellWidth
    height: wallpapersView.cellHeight

    checked: wallpapersView.currentIndex === index

    z: checked ? 2 : 0
}
