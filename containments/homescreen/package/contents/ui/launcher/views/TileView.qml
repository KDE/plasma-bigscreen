/*
 * Copyright 2019 Aditya Mehra <aix.m@outlook.com>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  2.010-1301, USA.
 */

import QtQuick 2.12
import QtQuick.Layouts 1.4
import QtQuick.Controls 2.4 as Controls

import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.private.biglauncher 1.0 as Launcher
import org.kde.kirigami 2.5 as Kirigami


ListView {
    id: view
    //TODO:dynamic
    property int columns: Math.max(3, Math.floor(width / (units.gridUnit * 12)))

    readonly property int cellWidth: width / columns

    property Item navigationUp
    property Item navigationDown

    Layout.fillWidth: true
    Layout.fillHeight: true

    z: activeFocus ? 10: 1
    keyNavigationEnabled: true
    //Centering disabled as experiment
    //highlightRangeMode: ListView.ApplyRange
    highlightFollowsCurrentItem: true
    snapMode: ListView.SnapToItem
    cacheBuffer: width

    //preferredHighlightBegin: width/view.columns
    //preferredHighlightEnd: width/view.columns * 2

    displayMarginBeginning: rotation.angle != 0 ? width*2 : 0
    displayMarginEnd: rotation.angle != 0 ? width*2 : 0
    highlightMoveDuration: Kirigami.Units.longDuration
    transform: Rotation {
        id: rotation
        axis { x: 0; y: 1; z: 0 }
        angle: 0
        property real targetAngle: 30
        Behavior on angle {
            SmoothedAnimation {
                duration: Kirigami.Units.longDuration * 10
            }
        }
        origin.x: width/2
    }

    Timer {
        id: rotateTimeOut
        interval: 25
    }
    Timer {
        id: rotateTimer
        interval: 500
        onTriggered: {
            if (rotateTimeOut.running) {
                rotation.angle = rotation.targetAngle;
                restart();
            } else {
                rotation.angle = 0;
            }
        }
    }
    spacing: 0
    orientation: ListView.Horizontal

    property real oldContentX
    onContentXChanged: {
        if (oldContentX < contentX) {
            rotation.targetAngle = 30;
        } else {
            rotation.targetAngle = -30;
        }
        PlasmaComponents.ScrollBar.horizontal.opacity = 1;
        if (!rotateTimeOut.running) {
            rotateTimer.restart();
        }
        rotateTimeOut.restart();
        oldContentX = contentX;
    }
    PlasmaComponents.ScrollBar.horizontal: PlasmaComponents.ScrollBar {
        id: scrollBar
        opacity: 0
        interactive: false
        onOpacityChanged: disappearTimer.restart()
        Timer {
            id: disappearTimer
            interval: 1000
            onTriggered: scrollBar.opacity = 0;
        }
        Behavior on opacity {
            OpacityAnimator {
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InOutQuad
            }
        }
    }

    move: Transition {
        SmoothedAnimation {
            property: "x"
            duration: Kirigami.Units.longDuration
        }
    }

    Keys.onDownPressed:  {
        if (!navigationDown) {
            return;
        }

        if (navigationDown instanceof TileView) {
            navigationDown.currentIndex = navigationDown.indexAt(navigationDown.contentItem.mapFromItem(currentItem, cellWidth/2, height/2).x, height/2);
        }

        navigationDown.forceActiveFocus();
    }

    Keys.onUpPressed:  {
        if (!navigationUp) {
            return;
        }

        if (navigationUp instanceof TileView) {
            navigationUp.currentIndex = navigationUp.indexAt(navigationUp.contentItem.mapFromItem(currentItem, cellWidth/2, height/2).x, height/2);
        }

        navigationUp.forceActiveFocus();
    }
}
