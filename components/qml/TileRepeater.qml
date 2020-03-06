 /*
 * Copyright 2020 Marco Martin <mart@kde.org>
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
import QtQuick.Window 2.2
import QtQuick.Controls 2.12 as Controls
import org.kde.kirigami 2.10 as Kirigami
import org.kde.mycroft.bigscreen 1.0 as BigScreen

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
    Layout.fillWidth: true
    
    implicitHeight: view.implicitHeight + header.implicitHeight

    //TODO:dynamic
    property int columns: Math.max(3, Math.floor(width / (units.gridUnit * 8)))

    property alias cellWidth: view.cellWidth
    readonly property real screenRatio: view.Window.window ? view.Window.window.width / view.Window.window.height : 1.6

    property Item navigationUp
    property Item navigationDown

    onActiveFocusChanged: {
        if (!activeFocus) {
            return;
        }

        // Update currentItem if needed
        view.currentIndexChanged();

        if (!currentItem) {
            return;
        }

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
        layer.enabled: true
        color: "white"
    }

    Flickable {
        id: view
        anchors {
            left: parent.left
            right: parent.right
            top: header.baseline
            bottom: parent.bottom
            topMargin: Kirigami.Units.largeSpacing*2
            leftMargin: -Kirigami.Units.largeSpacing
        }
        readonly property int cellWidth: (Kirigami.Units.iconSizes.huge + Kirigami.Units.largeSpacing*4)
        property int currentIndex: 0
        property alias count: repeater.count
        property alias model: repeater.model
        property alias delegate: repeater.delegate
        readonly property Item currentItem: layout.children[currentIndex]

        function indexAt(x,y) {
            return Math.max(0, Math.min(count - 1, Math.round(x/cellWidth)));
        }

        focus: true

        implicitHeight: cellWidth + units.gridUnit * 3
        contentWidth: layout.width
        contentHeight: height
        onCurrentItemChanged: {
            if (!currentItem) {
                return;
            }

            currentItem.forceActiveFocus();
            slideAnim.slideToIndex(currentIndex);
        }

        onMovementEnded: currentIndex = Math.min(count-1, Math.round((contentX + cellWidth) / cellWidth))
        onFlickEnded: movementEnded()

        NumberAnimation {
            id: slideAnim
            target: view
            property: "contentX"
            duration: 250

            function slideToIndex(index) {
                slideAnim.running = false;
                slideAnim.from = view.contentX;
                slideAnim.to = Math.max(0, view.cellWidth * (view.currentIndex-1));
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
                // Update currentItem if needed
                onChildrenChanged: view.currentIndexChanged();
            }

            // Spacer
            Item {
                width: view.width - view.cellWidth*2
                height: 1
            }
        }

        Keys.onLeftPressed: currentIndex = Math.max(0, currentIndex - 1)
        Keys.onRightPressed: currentIndex = Math.min(count - 1, currentIndex + 1)

        Keys.onDownPressed:  {
            if (!root.navigationDown) {
                return;
            }

            if (root.navigationDown instanceof TileView ||
                root.navigationDown instanceof TileRepeater) {
                root.navigationDown.currentIndex = Math.min(Math.floor(root.navigationDown.view.indexAt(root.navigationDown.view.contentX + cellWidth/2, height/2)) + (view.currentIndex - view.indexAt(view.contentX + cellWidth/2, height/2)), root.navigationDown.view.count - 1);

                if (root.navigationDown.currentIndex < 0) {
                    root.navigationDown.currentIndex = view.currentIndex > 0 ? root.navigationDown.view.count - 1 : 0
                }
            }

            root.navigationDown.forceActiveFocus();
        }

        Keys.onUpPressed:  {
            if (!root.navigationUp) {
                return;
            }

            if (root.navigationUp instanceof TileView ||
                root.navigationUp instanceof TileRepeater) {
                root.navigationUp.currentIndex = Math.min(Math.floor(root.navigationUp.view.indexAt(root.navigationUp.view.contentX + cellWidth/2, height/2)) + (view.currentIndex - view.indexAt(view.contentX + cellWidth/2, height/2)), root.navigationUp.view.count - 1);

                if (root.navigationUp.currentIndex < 0) {
                    root.navigationUp.currentIndex = view.currentIndex > 0 ? root.navigationUp.view.count - 1 : 0
                }
            }

            root.navigationUp.forceActiveFocus();
        }
    }
}
