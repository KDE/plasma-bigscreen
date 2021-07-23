/*
    SPDX-FileCopyrightText: 2019 Aditya Mehra <aix.m@outlook.com>

    SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
*/

import QtQuick 2.14
import QtQuick.Layouts 1.14
import org.kde.kirigami 2.12 as Kirigami
import QtQuick.Controls 2.14
import org.kde.plasma.core 2.1 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.private.volume 0.1
import QtQuick.Window 2.14
import org.kde.kcm 1.1 as KCM

import "delegates" as Delegates
import "views" as Views

KCM.SimpleKCM {
    id: root
    title: i18n("Audio Device Chooser")
    
    signal activateDeviceView

    background: null
    leftPadding: Kirigami.Units.smallSpacing
    topPadding: 0
    rightPadding: Kirigami.Units.smallSpacing
    bottomPadding: 0

    Label {
        id: textMetrics
        visible: false
        text: "/II/"
    }
    
    Component.onCompleted: {
        root.activateDeviceView
    }

    contentItem: DeviceChooserPage {
        id: deviceChooserView
    }
}
