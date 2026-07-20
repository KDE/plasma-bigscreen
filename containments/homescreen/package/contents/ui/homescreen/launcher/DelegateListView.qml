 /*
  * SPDX-FileCopyrightText: 2022 Aditya Mehra <aix.m@outlook.com>
  * SPDX-FileCopyrightText: 2020 Marco Martin <mart@kde.org>
  *
  * SPDX-License-Identifier: GPL-2.0-or-later
  */

import QtQuick
import QtQuick.Layouts
import QtQuick.Window
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami
import org.kde.bigscreen as Bigscreen

FocusScope {
    id: root
    signal activated

    property string title

    property alias view: view
    property alias delegate: view.delegate
    property alias model: view.model
    property alias currentIndex: view.currentIndex
    property alias currentItem: view.currentItem
    property alias count: view.count
    property bool titleVisible: true

    Layout.fillWidth: true
    implicitHeight: view.implicitHeight + header.implicitHeight

    // Responsive grid logic
    property real columns: {
        const windowWidth = root.Window.width || 0;
        if (windowWidth > 1280) return 5.5;
        if (windowWidth > 1024) return 4.5;
        return 3.5;
    }

    property alias cellWidth: view.cellWidth
    property alias cellHeight: view.cellHeight
    readonly property real screenRatio: view.Window.window ? view.Window.window.width / view.Window.window.height : 1.6

    property Item navigationUp
    property Item navigationDown


    onActiveFocusChanged: {
        if (activeFocus && currentItem) {
            currentItem.forceActiveFocus();
        }
    }

    Kirigami.Heading {
        id: header
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }
        text: title
        font.pixelSize: 32
        font.weight: Font.Light
        color: 'white'
        visible: root.titleVisible
    }

    ListView {
        id: view
        property var listView: view
        anchors {
            left: parent.left
            right: parent.right
            top: header.bottom
            bottom: parent.bottom
            topMargin: Kirigami.Units.largeSpacing * 2
        }
        readonly property int cellWidth: root.width / columns + Kirigami.Units.gridUnit
        property int cellHeight: cellWidth * 0.75

        implicitHeight: cellHeight
        
        keyNavigationEnabled: true
        reuseItems: true
        focus: true
        snapMode: ListView.SnapOneItem
        cacheBuffer: width * 2
        spacing: 0
        orientation: ListView.Horizontal

        highlightMoveVelocity: -1
        highlightMoveDuration: Kirigami.Units.longDuration
        // highlightRangeMode: ListView.ApplyRange

        preferredHighlightBegin: 0
        preferredHighlightEnd: cellWidth
        displayMarginBeginning: cellWidth
        displayMarginEnd: cellWidth

        onCurrentIndexChanged: {
            var item = itemAtIndex(currentIndex);
            if (item) { 
                const maxContentX = Math.max(0, contentWidth - width);
                xAnim.to = Math.max(0, Math.min(item.x - cellWidth, maxContentX));
                xAnim.restart();
            }
        }

        NumberAnimation on contentX {
            id: xAnim
            easing.type: Easing.OutCubic
            duration: Kirigami.Units.longDuration
        }

        onMovementEnded: flickEnded()

        onFlickEnded: currentIndex = indexAt(mapToItem(contentItem, cellWidth, 0).x, 0)

        move: Transition {
            SmoothedAnimation {
                property: "x"
                duration: Kirigami.Units.longDuration
            }
        }

        Keys.onLeftPressed: (event) => {
            if (currentIndex > 0) {
                Bigscreen.NavigationSoundEffects.playMovingSound();
                currentIndex = Math.max(0, currentIndex - 1);
                event.accepted = true;
            } else {
                event.accepted = false;
            }
        }

        Keys.onRightPressed: (event) => {
            if (currentIndex < count - 1) {
                Bigscreen.NavigationSoundEffects.playMovingSound();
                currentIndex = Math.min(count - 1, currentIndex + 1);
                event.accepted = true;
            } else {
                event.accepted = false;
            }
        }

        Keys.onDownPressed: {
            if (!root.navigationDown) return;
            Bigscreen.NavigationSoundEffects.playMovingSound();
            root.navigationDown.forceActiveFocus();
        }

        Keys.onUpPressed: {
            if (!root.navigationUp) return;
            Bigscreen.NavigationSoundEffects.playMovingSound();
            root.navigationUp.forceActiveFocus();
        }
    }
}