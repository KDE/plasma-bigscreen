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
import org.kde.kirigami 2.13 as Kirigami
import org.kde.mycroft.bigscreen 1.0 as BigScreen

AbstractDelegate {
    id: delegate

    implicitWidth: listView.cellWidth
    implicitHeight: listView.height

    property var iconImage
    property string comment
    property bool useIconColors: true
    property bool compactMode: false

    Kirigami.Theme.inherit: !imagePalette.useColors
    Kirigami.Theme.textColor: imagePalette.textColor
    Kirigami.Theme.backgroundColor: imagePalette.backgroundColor
    Kirigami.Theme.highlightColor: imagePalette.accentColor

    Kirigami.ImageColors {
        id: imagePalette
        source: iconItem.source
        property bool useColors: useIconColors
        property color backgroundColor: useColors ? dominantContrast : PlasmaCore.ColorScope.backgroundColor
        property color accentColor: useColors ? highlight : PlasmaCore.ColorScope.highlightColor
        property color textColor: useColors
            ? Kirigami.ColorUtils.brightness(dominantContrast) === Kirigami.ColorUtils.Light ? imagePalette.closestToBlack : imagePalette.closestToWhite
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
            anchors {
                left: content.left
                right: content.right
                top: iconItem.bottom
                bottom: content.bottom
                leftMargin: 0
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
                id: commentLabel
                // keeps commentLabel from affecting the vertical center of label when not selected
                visible: text.length > 0 && (toSelectedTransition.running || toNormalTransition.running || delegate.isCurrent || !delegate.compactMode)
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
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
                when: delegate.isCurrent || !delegate.compactMode
                PropertyChanges {
                    target: delegate
                    implicitWidth: delegate.compactMode ? (listView.cellWidth * 2) : listView.cellWidth
                }
                PropertyChanges {
                    target: iconItem
                    y: content.height/2 - iconItem.height/2
                }
                AnchorChanges {
                    target: textLayout
                    anchors.left: iconItem.right
                    anchors.right: content.right
                    anchors.top: iconItem.top
                    anchors.bottom: iconItem.bottom
                }
                PropertyChanges {
                    target: textLayout
                    anchors.leftMargin: Kirigami.Units.smallSpacing
                }
                PropertyChanges {
                    target: commentLabel
                    opacity: 1
                }
            },
            State {
                name: "normal"
                when: !delegate.isCurrent && delegate.compactMode
                PropertyChanges {
                    target: delegate
                    implicitWidth: listView.cellWidth
                }
                PropertyChanges {
                    target: iconItem
                    y: 0
                }
                AnchorChanges {
                    target: textLayout
                    anchors.left: content.left
                    anchors.right: content.right
                    anchors.top: iconItem.bottom
                    anchors.bottom: content.bottom
                }
                PropertyChanges {
                    target: textLayout
                    anchors.leftMargin: 0
                }
                PropertyChanges {
                    target: commentLabel
                    opacity: 0
                }
            }
        ]
        transitions: [
            Transition {
                id: toSelectedTransition
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
                    AnchorAnimation {
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
                id: toNormalTransition
                to: "normal"
                ParallelAnimation {
                    XAnimator {
                        duration: Kirigami.Units.longDuration
                        easing.type: Easing.InOutQuad
                    }
                    YAnimator {
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
                    AnchorAnimation {
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
