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
            var v = root.compactMode ? 7.5 : 5.5;
            switch (true) {
                case (view.Window.window.width <= 1280 && view.Window.window.width > 1024):
                    v = root.compactMode ? 6.5 : 4.5;
                    break;
                case (view.Window.window.width <= 1024 && view.Window.window.width > 800):
                    v = root.compactMode ? 5.5 : 3.5;
                    break;
                case (view.Window.window.width <= 800):
                    v = root.compactMode ? 4.5 : 2.5;
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

    property bool compactMode: false
    property Item navigationUp
    property Item navigationDown

    onActiveFocusChanged: {
        if (!activeFocus) return;
        view.currentIndexChanged();
        if (!currentItem) return;
        currentItem.forceActiveFocus();
    }

    Kirigami.ShadowedRectangle {
        id: headerBackground
        width: header.contentWidth + Kirigami.Units.largeSpacing * 2
        height: header.implicitHeight
        anchors {
            left: parent.left
            leftMargin: -Kirigami.Units.largeSpacing
            top: parent.top
        }
        color: Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 0.7)
        radius: 6
        shadow {
            size: Kirigami.Units.largeSpacing
        }
        visible: root.titleVisible
    }

    Kirigami.Heading {
        id: header
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }
        text: title
        layer.enabled: true
        font.pixelSize: 28
        color: Kirigami.Theme.textColor
        visible: root.titleVisible
    }

    Flickable {
        id: view
        anchors {
            left: parent.left
            right: parent.right
            top: header.baseline
            bottom: parent.bottom
            topMargin: Kirigami.Units.largeSpacing * 2
            leftMargin: -Kirigami.Units.largeSpacing
        }
        readonly property int cellWidth: root.width / columns + (Kirigami.Units.gridUnit / 1)
        property int cellHeight: root.compactMode ? cellWidth + Kirigami.Units.gridUnit * 2 : cellWidth * 0.75
        property int currentIndex: 0
        property alias count: repeater.count
        property alias model: repeater.model
        property alias delegate: repeater.delegate
        readonly property Item currentItem: layout.children[currentIndex]

        function indexAt(x, y) {
            return Math.max(0, Math.min(count - 1, Math.round(x / cellWidth)));
        }

        focus: true
        implicitHeight: cellHeight
        contentWidth: layout.width
        contentHeight: height

        onCurrentItemChanged: {
            if (!currentItem) return;
            currentItem.forceActiveFocus();
            slideAnim.slideToIndex(currentIndex);
        }

        onMovementEnded: currentIndex = Math.min(count - 1, Math.round((contentX + cellWidth) / cellWidth))
        onFlickEnded: movementEnded()

        NumberAnimation {
            id: slideAnim
            target: view
            property: "contentX"
            duration: 250

            function slideToIndex(index) {
                slideAnim.running = false;
                slideAnim.from = view.contentX;
                slideAnim.to = Math.max(0, view.cellWidth * view.currentIndex);
                slideAnim.restart();
            }
        }

        Row {
            id: layout
            anchors {
                top: parent.top
                bottom: parent.bottom
            }
            spacing: 0

            Repeater {
                id: repeater
                onChildrenChanged: view.currentIndexChanged();
            }

            // Spacer
            Item {
                width: view.width - view.cellWidth * 2
                height: 1
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
