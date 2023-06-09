/*
    SPDX-FileCopyrightText: 2019 Aditya Mehra <aix.m@outlook.com>
    SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.14
import QtQuick.Layouts 1.14
import QtQuick.Controls 2.14 as Controls
import QtQuick.Window 2.14
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kirigami 2.12 as Kirigami


ListView {
    id: view
    property int columns: 3//Math.max(3, Math.floor(width / (units.gridUnit * 15)))

    readonly property int cellWidth: Math.floor(width / columns )

    property Item navigationUp
    property Item navigationDown

    Layout.fillWidth: true
    //Layout.fillHeight: true
    Layout.preferredHeight: Math.floor(cellWidth/screenRatio)
    readonly property real screenRatio: 0.95 //view.Window.window ? 0.9 : 1.6
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

    opacity: Kirigami.ScenePosition.y >= 0
    Behavior on opacity {
        OpacityAnimator {
            duration: Kirigami.Units.longDuration * 2
            easing.type: Easing.InOutQuad
        }
    }

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

    Behavior on x {
        //Can't be an Animator
        NumberAnimation {
            duration: Kirigami.Units.longDuration * 2
            easing.type: Easing.InOutQuad
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
