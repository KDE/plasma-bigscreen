/*
    SPDX-FileCopyrightText: 2019 Aditya Mehra <aix.m@outlook.com>

    SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.plasma.private.volume
import QtQuick.Window
import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami

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
    
    property Item settingMenuItem: root.parent.parent.lastSettingMenuItem

    function settingMenuItemFocus() {
        settingMenuItem.forceActiveFocus()
    }

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
