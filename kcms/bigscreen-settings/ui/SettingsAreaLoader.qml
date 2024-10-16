/*
    SPDX-FileCopyrightText: 2020 Aditya Mehra <aix.m@outlook.com>
    SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL
*/

import QtQuick.Layouts
import QtQuick
import QtQuick.Window
import QtQuick.Controls
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import "delegates" as Delegates

Rectangle {
    id: settingsAreaLoader
    color: Kirigami.Theme.backgroundColor 
    property var settingsAreaComponent
    property var setActionPath
    property var getActionPath
    property var currentShortcut

    Kirigami.Separator {
        id: separator
        width: 1
        color: Kirigami.Theme.disabledTextColor

        anchors {
            top: parent.top
            bottom: parent.bottom
            left: parent.left
        }
    }

    onActiveFocusChanged: {
        if(activeFocus){
            contentItem.forceActiveFocus()
        }
    }

    Loader {
        id: contentItem
        anchors.fill: parent
        source: settingsAreaComponent

        onStatusChanged: {
            if (status === Loader.Ready) {
                item.forceActiveFocus()
            }
        }
    }
}
