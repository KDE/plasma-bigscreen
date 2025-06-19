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

    property real columns: {
        if (view.Window && view.Window.window) {
            var v = 5.5;
            switch (true) {
                case (view.Window.window.width <= 1280 && view.Window.window.width > 1024):
                    v = 4.5;
                    break;
                case (view.Window.window.width <= 1024 && view.Window.window.width > 800):
                    v = 3.5;
                    break;
                case (view.Window.window.width <= 800):
                    v = 2.5;
                    break;
            }
            return v;
        } else {
            return 0; // or any default value you prefer
        }
    }


    property alias cellWidth: view.cellWidth
    property alias cellHeight: view.cellHeight
    readonly property real screenRatio: view.Window.window ? view.Window.window.width / view.Window.window.height : 1.6

    property Item navigationUp
    property Item navigationDown

    onActiveFocusChanged: {
        if (!activeFocus) return;
        view.currentIndexChanged();
        if (!currentItem) return;
        currentItem.forceActiveFocus();
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
            top: header.baseline
            bottom: parent.bottom
            topMargin: Kirigami.Units.largeSpacing * 2
        }
        readonly property int cellWidth: root.width / columns + (Kirigami.Units.gridUnit / 1)
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

        preferredHighlightBegin: 0
        preferredHighlightEnd: cellWidth
        displayMarginBeginning: cellWidth
        displayMarginEnd: cellWidth

        onMovementEnded: flickEnded()

        onFlickEnded: currentIndex = indexAt(mapToItem(contentItem, cellWidth, 0).x, 0)

        move: Transition {
            SmoothedAnimation {
                property: "x"
                duration: Kirigami.Units.longDuration
            }
        }

        Keys.onLeftPressed: {
            if (currentIndex > 0) {
                Bigscreen.NavigationSoundEffects.playMovingSound();
                currentIndex = Math.max(0, currentIndex - 1);
            }
        }

        Keys.onRightPressed: {
            if (currentIndex < count - 1) {
                Bigscreen.NavigationSoundEffects.playMovingSound();
                currentIndex = Math.min(count - 1, currentIndex + 1);
            }
        }

        Keys.onDownPressed: {
            if (!root.navigationDown) return;
            Bigscreen.NavigationSoundEffects.playMovingSound();
            if (root.navigationDown instanceof TileView || root.navigationDown instanceof TileRepeater) {
                root.navigationDown.currentIndex = Math.min(Math.floor(root.navigationDown.view.indexAt(root.navigationDown.view.contentX, height / 2)), root.navigationDown.view.count - 1);
                if (root.navigationDown.currentIndex < 0) root.navigationDown.currentIndex = view.currentIndex > 0 ? root.navigationDown.view.count - 1 : 0;
            }
            root.navigationDown.forceActiveFocus();
        }

        Keys.onUpPressed: {
            if (!root.navigationUp) return;
            Bigscreen.NavigationSoundEffects.playMovingSound();
            if (root.navigationUp instanceof TileView || root.navigationUp instanceof TileRepeater) {
                root.navigationUp.currentIndex = Math.min(Math.floor(root.navigationUp.view.indexAt(root.navigationUp.view.contentX, height / 2)), root.navigationUp.view.count - 1);
                if (root.navigationUp.currentIndex < 0) root.navigationUp.currentIndex = view.currentIndex > 0 ? root.navigationUp.view.count - 1 : 0;
            }
            root.navigationUp.forceActiveFocus();
        }
    }
}
