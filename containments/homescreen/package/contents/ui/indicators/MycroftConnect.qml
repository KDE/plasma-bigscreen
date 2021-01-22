/*
    SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2019 Aditya Mehra <aix.m@outlook.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.9
import Mycroft 1.0 as Mycroft

Item {
    function sendText(utterance) {
         Mycroft.MycroftController.sendText(utterance)
    }

    Component.onCompleted: Mycroft.MycroftController.start()
}
