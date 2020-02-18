/*
 *  Copyright 2019 Aditya Mehra <aix.m@outlook.com>
 *  Copyright 2019 Marco Martin <mart@kde.org>
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

import QtQuick 2.9
import QtQuick.Layouts 1.3

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kirigami 2.11 as Kirigami
import org.kde.mycroft.bigscreen 1.0 as BigScreen

PlasmaComponents.ItemDelegate {
    id: delegate

    implicitWidth: isCurrent ? listView.cellWidth * 2 : listView.cellWidth
    implicitHeight: listView.height

    readonly property ListView listView: ListView.view
    readonly property bool isCurrent: listView.currentIndex == index && activeFocus
    property string comment

    z: isCurrent ? 2 : 0
    onClicked: {
        listView.forceActiveFocus()
        console.log(index)
        listView.currentIndex = index
        console.log(listView.currentIndex)
    }

    leftPadding: units.largeSpacing*2
    topPadding: units.largeSpacing*2
    rightPadding: units.largeSpacing*2
    bottomPadding: units.largeSpacing*2

    Behavior on implicitWidth {
        NumberAnimation {
            duration: Kirigami.Units.longDuration
            easing.type: Easing.InOutQuad
        }
    }

    Keys.onReturnPressed: {
        clicked();
    }

    BigScreen.ImagePalette {
        id: imagePalette
        sourceItem: icon
        property bool useColors: BigScreen.Hack.coloredTiles
        property color backgroundColor: useColors ? suggestedContrast : PlasmaCore.ColorScope.backgroundColor
        property color accentColor: useColors ? mostSaturated : PlasmaCore.ColorScope.highlightColor
        property color textColor: useColors
            ? (0.2126 * suggestedContrast.r + 0.7152 * suggestedContrast.g + 0.0722 * suggestedContrast.b > 0.6 ? Qt.rgba(0.2,0.2,0.2,1) : Qt.rgba(0.9,0.9,0.9,1))
            : PlasmaCore.ColorScope.textColor

        readonly property bool inView: listView.width - delegate.x - icon.x < listView.contentX
        onInViewChanged: {
            if (inView) {
                imagePalette.update();
            }
        }
    }
    background: Item {
        id: background

        PlasmaCore.FrameSvgItem {
            anchors {
                fill: frame
                leftMargin: -margins.left
                topMargin: -margins.top
                rightMargin: -margins.right
                bottomMargin: -margins.bottom
            }
            imagePath: Qt.resolvedUrl("./background.svg")
            prefix: "shadow"
        }
        Rectangle {
            id: frame
            anchors {
                fill: parent
                margins: units.largeSpacing
            }
            radius: units.gridUnit/5
            color: delegate.isCurrent ? imagePalette.accentColor : imagePalette.backgroundColor
            Behavior on color {
                ColorAnimation {
                    duration: Kirigami.Units.longDuration
                    easing.type: Easing.InOutQuad
                }
            }
            Rectangle {
                anchors {
                    fill: parent
                    margins: units.smallSpacing
                }
                radius: units.gridUnit/5
                color: imagePalette.backgroundColor
            }
        }
    }
    
    contentItem: Item {
        id: content
        PlasmaCore.IconItem {
            id: icon
            width: listView.cellWidth - delegate.leftPadding - (delegate.isCurrent ? 0 : delegate.rightPadding)
            height: width
            source: delegate.icon.name || delegate.icon.source
            Behavior on width {
                NumberAnimation {
                    duration: Kirigami.Units.longDuration
                    easing.type: Easing.InOutQuad
                }
            }
        }

        ColumnLayout {
            width: listView.cellWidth - delegate.leftPadding -  delegate.rightPadding
            anchors.right: parent.right
            y: delegate.isCurrent ? content.height/2 - height/2 : content.height - label.height
            Behavior on x {
                XAnimator {
                    duration: Kirigami.Units.longDuration
                    easing.type: Easing.InOutQuad
                }
            }
            Behavior on y {
                YAnimator {
                    duration: Kirigami.Units.longDuration
                    easing.type: Easing.InOutQuad
                }
            }

            PlasmaComponents.Label {
                id: label
                visible: text.length > 0
                Layout.fillWidth: true

                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                maximumLineCount: 2
                elide: Text.ElideRight
                color: imagePalette.textColor

                text: delegate.text
            }
            PlasmaComponents.Label {
                visible: text.length > 0
                Layout.fillWidth: true

                opacity: delegate.isCurrent
                Behavior on opacity {
                    OpacityAnimator {
                        duration: Kirigami.Units.longDuration
                        easing.type: Easing.InOutQuad
                    }
                }
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                maximumLineCount: 2
                elide: Text.ElideRight
                color: imagePalette.textColor

                text: delegate.comment
            }
        }
    }
}
