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
import QtGraphicalEffects 1.12

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kirigami 2.11 as Kirigami
import org.kde.mycroft.bigscreen 1.0 as BigScreen

AbstractDelegate {
    id: delegate

    implicitWidth: listView.cellWidth
    implicitHeight: listView.height

    property var iconImage
    property string comment

    Kirigami.Theme.inherit: !imagePalette.useColors
    Kirigami.Theme.textColor: imagePalette.textColor
    Kirigami.Theme.backgroundColor: imagePalette.backgroundColor
    Kirigami.Theme.highlightColor: imagePalette.accentColor

    BigScreen.ImagePalette {
        id: imagePalette
        source: iconItem.source
        property bool useColors: BigScreen.Hack.coloredTiles
        property color backgroundColor: useColors ? suggestedContrast : PlasmaCore.ColorScope.backgroundColor
        property color accentColor: useColors ? mostSaturated : PlasmaCore.ColorScope.highlightColor
        property color textColor: useColors
            ? (0.2126 * suggestedContrast.r + 0.7152 * suggestedContrast.g + 0.0722 * suggestedContrast.b > 0.6 ? Qt.rgba(0.2,0.2,0.2,1) : Qt.rgba(0.9,0.9,0.9,1))
            : PlasmaCore.ColorScope.textColor
    }
    
    contentItem: Item {
        id: content

        PlasmaCore.IconItem {
            id: iconItem
            //Icon should cover text during animation
            z: 1
            width: Kirigami.Units.iconSizes.huge
            height: width
            source: delegate.iconImage || delegate.icon.name || delegate.icon.source
        }

        ColumnLayout {
            id: textLayout
            anchors.right: content.right

            x: 0
            y: content.height - label.height
            width: parent.width - x

            PlasmaComponents.Label {
                id: label
                visible: text.length > 0
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                horizontalAlignment: delegate.isCurrent || !Hack.compactTiles ? Text.AlignLeft : Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                maximumLineCount: 2
                elide: Text.ElideRight
                color: imagePalette.textColor

                text: delegate.text
            }
            PlasmaComponents.Label {
                id: commentLabel
                visible: text.length > 0
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                maximumLineCount: 2
                elide: Text.ElideRight
                color: imagePalette.textColor
                opacity: 0

                text: delegate.comment
            }
        }
        states: [
            State {
                name: "selected"
                when: delegate.isCurrent || !Hack.compactTiles
                PropertyChanges {
                    target: delegate
                    implicitWidth: Hack.compactTiles ? listView.cellWidth * 2 : listView.cellWidth
                }
                PropertyChanges {
                    target: iconItem
                    width: Kirigami.Units.iconSizes.huge + Kirigami.Units.largeSpacing*2
                    y: content.height/2 - iconItem.height/2
                }
                PropertyChanges {
                    target: textLayout
                    x: iconItem.width + Kirigami.Units.largeSpacing
                    y: content.height/2 - textLayout.height/2
                }
                PropertyChanges {
                    target: commentLabel
                    opacity: 1
                }
            },
            State {
                name: "normal"
                when: !delegate.isCurrent || !Hack.compactTiles
                PropertyChanges {
                    target: delegate
                    implicitWidth: listView.cellWidth
                }
                PropertyChanges {
                    target: iconItem
                    width: Kirigami.Units.iconSizes.huge
                    y: 0
                }
                PropertyChanges {
                    target: textLayout
                    x: 0
                    y: content.height - label.height
                }
                PropertyChanges {
                    target: commentLabel
                    opacity: 0
                }
            }
        ]
        transitions: [
            Transition {
                to: "selected"
                ParallelAnimation {
                    XAnimator {
                        duration: Kirigami.Units.longDuration
                        easing.type: Easing.InOutQuad
                    }
                    NumberAnimation {
                        property: "y"
                        duration: Kirigami.Units.longDuration
                        easing.type: Easing.InOutQuad
                    }
                    NumberAnimation {
                        property: "width"
                        duration: Kirigami.Units.longDuration
                        easing.type: Easing.InOutQuad
                    }
                    NumberAnimation {
                        property: "implicitWidth"
                        duration: Kirigami.Units.longDuration
                        easing.type: Easing.InOutQuad
                    }
                    SequentialAnimation {
                        PauseAnimation {
                            duration: Kirigami.Units.longDuration/2
                        }
                        OpacityAnimator {
                            target: commentLabel
                            duration: Kirigami.Units.longDuration/2
                            easing.type: Easing.InOutQuad
                        }
                    }
                }
            },
            Transition {
                to: "normal"
                ParallelAnimation {
                    XAnimator {
                        duration: Kirigami.Units.longDuration
                        easing.type: Easing.InOutQuad
                    }
                    // FIXME: why a YAnimator doesn't work?
                    NumberAnimation {
                        property: "y"
                        duration: Kirigami.Units.longDuration
                        easing.type: Easing.InOutQuad
                    }
                    NumberAnimation {
                        property: "width"
                        duration: Kirigami.Units.longDuration
                        easing.type: Easing.InOutQuad
                    }
                    NumberAnimation {
                        property: "implicitWidth"
                        duration: Kirigami.Units.longDuration
                        easing.type: Easing.InOutQuad
                    }
                    OpacityAnimator {
                        target: commentLabel
                        duration: Kirigami.Units.longDuration/2
                        easing.type: Easing.InOutQuad
                    }
                }
            }
        ]
    }
}
