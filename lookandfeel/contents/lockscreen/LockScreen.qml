/*
    SPDX-FileCopyrightText: 2014 Aleix Pol Gonzalez <aleixpol@blue-systems.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.15
import QtQuick.Controls 2.15
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.private.sessions 2.0
import "../components"

Image {
    id: root
    property int interfaceVersion: org_kde_plasma_screenlocker_greeter_interfaceVersion ? org_kde_plasma_screenlocker_greeter_interfaceVersion : 0

    source: backgroundPath
    fillMode: Image.PreserveAspectCrop
    asynchronous: true
    function unlock() {
        authenticator.tryUnlock("mycroft")
    }
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onPositionChanged: (mouse)=> { 
            root.unlock()
        }
        onClicked: (mouse)=> {
            root.unlock()
        }
    }
    Keys.onPressed: (event)=> {
        root.unlock()
    }
}
