/*
    SPDX-FileCopyrightText: 2019 Aditya Mehra <aix.m@outlook.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15 as Controls

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kirigami 2.15 as Kirigami
import Qt5Compat.GraphicalEffects

FocusScope {
    id: root
    signal activated
    property string title
    property alias view: view
    property alias delegate: view.delegate
    property alias model: view.model
    property alias currentIndex: view.currentIndex
    property alias currentItem: view.currentItem
    Layout.fillWidth: true
    
    implicitHeight: view.implicitHeight + header.implicitHeight

    //TODO:dynamic
    property int columns: Math.max(3, Math.floor(width / (units.gridUnit * 8)))

    property alias cellWidth: view.cellWidth
    property alias cellHeight: view.cellHeight
    readonly property real screenRatio: view.Window.window ? view.Window.window.width / view.Window.window.height : 1.6

    property Item navigationUp
    property Item navigationDown

    Kirigami.Heading {
        id: header
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }
        text: title
        layer.enabled: true
        color: "white"
    }
    
    ListView {
        id: view
        anchors {
            left: parent.left
            right: parent.right
            top: header.baseline
            bottom: parent.bottom
            topMargin: Kirigami.Units.largeSpacing*2
            leftMargin: -Kirigami.Units.largeSpacing
        }
        focus: true

        z: activeFocus ? 10: 1
        keyNavigationEnabled: true
        //Centering disabled as experiment
        highlightRangeMode: ListView.ApplyRange

        highlightFollowsCurrentItem: true
        snapMode: ListView.SnapToItem
        cacheBuffer: width
        implicitHeight: cellHeight
        rightMargin: width-cellWidth
        property int cellWidth: (PlasmaCore.Units.iconSizes.huge + Kirigami.Units.largeSpacing*4)
        property int cellHeight: cellWidth + units.gridUnit * 3
        preferredHighlightBegin: 0
        preferredHighlightEnd: cellWidth
        displayMarginBeginning: cellWidth
        displayMarginEnd: cellWidth

        highlightMoveVelocity: -1
        highlightMoveDuration: Kirigami.Units.longDuration

        onContentWidthChanged: if (view.currentIndex === 0) view.contentX = view.originX

        onMovementEnded: flickEnded()
        onFlickEnded: currentIndex = indexAt(mapToItem(contentItem, cellWidth, 0).x, 0)
        
        spacing: 0
        orientation: ListView.Horizontal

        move: Transition {
            SmoothedAnimation {
                property: "x"
                duration: Kirigami.Units.longDuration
            }
        }

        KeyNavigation.left: root
        KeyNavigation.right: root

        Keys.onDownPressed: (event)=> {
            if (!navigationDown) {
                return;
            }

            if (navigationDown instanceof TileView) {
                navigationDown.currentIndex = Math.min(Math.floor(navigationDown.view.indexAt(navigationDown.view.contentX + cellWidth/2, height/2)) + (view.currentIndex - view.indexAt(view.contentX + cellWidth/2, height/2)), navigationDown.view.count - 1);

                if (navigationDown.currentIndex < 0) {
                    navigationDown.currentIndex = view.currentIndex > 0 ? navigationDown.view.count - 1 : 0
                }
            }

            navigationDown.forceActiveFocus();
        }

        Keys.onUpPressed: (event)=> {
            if (!navigationUp) {
                return;
            }

            if (navigationUp instanceof TileView) {
                navigationUp.currentIndex = Math.min(Math.floor(navigationUp.view.indexAt(navigationUp.view.contentX + cellWidth/2, height/2)) + (view.currentIndex - view.indexAt(view.contentX + cellWidth/2, height/2)), navigationUp.view.count - 1);

                if (navigationUp.currentIndex < 0) {
                    navigationUp.currentIndex = view.currentIndex > 0 ? navigationUp.view.count - 1 : 0
                }
            }

            navigationUp.forceActiveFocus();
        }
    }
}
