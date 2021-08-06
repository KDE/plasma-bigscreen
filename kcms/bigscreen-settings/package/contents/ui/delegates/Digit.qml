/*
 *   SPDX-FileCopyrightText: 2021 Aditya Mehra <aix.m@outlook.com>
 *   SPDX-FileCopyrightText: 2011 Marco Martin <mart@kde.org>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.14
import org.kde.kirigami 2.12 as Kirigami

Item {
    id: root

    property alias model: spinnerView.model
    property alias currentIndex: spinnerView.currentIndex
    property alias delegate: spinnerView.delegate
    property alias moving: spinnerView.moving
    property int selectedIndex: -1
    property int fontSize: 14

    width: parent.width / 3
    height: parent.height

    Text {
        id: placeHolder
        visible: false
        font.pointSize: root.fontSize
        text: "00"
    }

    Keys.onUpPressed: {
        spinnerView.incrementCurrentIndex()
        selectedIndex = spinnerView.ownIndex
    }

    Keys.onDownPressed: {
        spinnerView.decrementCurrentIndex()
        selectedIndex = spinnerView.ownIndex
    }

    PathView {
        id: spinnerView
        anchors.fill: parent
        model: 60
        clip: true
        pathItemCount: 5
        dragMargin: 800
        preferredHighlightBegin: 0.5
        preferredHighlightEnd: 0.5
        property int ownIndex: currentIndex

        delegate: Text {
            horizontalAlignment: Text.AlignHCenter
            width: spinnerView.width
            text: index < 10 ? "0"+index : index
            color: root.focus && root.currentIndex == index ? Kirigami.Theme.linkColor : Kirigami.Theme.textColor
            font.pointSize: root.fontSize
            opacity: PathView.itemOpacity
        }

        onMovingChanged: {
            userConfiguring = true
            if (!moving) {
                selectedIndex = spinnerView.ownIndex
            }
        }

        path: Path {
            startX: spinnerView.width/2
            startY: spinnerView.height + 1.5*placeHolder.height
            PathAttribute { name: "itemOpacity"; value: 0 }
            PathLine {
                x: spinnerView.width/2
                y: spinnerView.height/2
            }
            PathAttribute { name: "itemOpacity"; value: 1 }
            PathLine {
                x: spinnerView.width/2
                y: -1.5*placeHolder.height
            }
            PathAttribute { name: "itemOpacity"; value: 0 }
        }
    }
}

