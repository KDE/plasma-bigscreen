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

import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.12

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kirigami 2.11 as Kirigami
import org.kde.mycroft.bigscreen 1.0 as BigScreen

PlasmaComponents.ItemDelegate {
    id: delegate

    readonly property Flickable listView: {
        var candidate = parent;
        while (candidate) {
            if (candidate instanceof Flickable) {
                return candidate;
            }
            candidate = candidate.parent;
        }
        return null;
    }
    readonly property bool isCurrent: {//print(text+index+" "+listView.currentIndex+activeFocus+" "+listView.moving)
        listView.currentIndex == index && activeFocus && !listView.moving
    }
Component.onCompleted: Kirigami.Units.longDuration=1000
    property int borderSize: units.smallSpacing
    z: isCurrent ? 2 : 0

    onClicked: {
        listView.forceActiveFocus()
        listView.currentIndex = index
    }

    leftPadding: Kirigami.Units.largeSpacing * 2
    topPadding: Kirigami.Units.largeSpacing * 2
    rightPadding: Kirigami.Units.largeSpacing * 2
    bottomPadding: Kirigami.Units.largeSpacing * 2

    leftInset: Kirigami.Units.largeSpacing
    topInset: Kirigami.Units.largeSpacing
    rightInset: Kirigami.Units.largeSpacing
    bottomInset: Kirigami.Units.largeSpacing

    Keys.onReturnPressed: {
        clicked();
    }

    contentItem: Item {}

    background: Item {
        id: background

        readonly property Item highlight: Rectangle {
            parent: delegate
            z: 1
            anchors {
                fill: parent
                leftMargin: delegate.leftInset
                topMargin: delegate.topInset
                rightMargin: delegate.rightInset
                bottomMargin: delegate.bottomInset
            }
            color: "transparent"
            border {
                width: delegate.borderSize
                color: delegate.Kirigami.Theme.highlightColor
            }
            opacity: delegate.isCurrent
            Behavior on opacity {
                OpacityAnimator {
                    duration: Kirigami.Units.longDuration/2
                    easing.type: Easing.InOutQuad
                }
            }
        }

        Rectangle {
            id: shadowSource
            anchors {
                fill: frame
                margins: delegate.borderSize
            }
            color: "black"
            radius: frame.radius
            visible: false
        }

        FastBlur {
            anchors.fill: frame
            transparentBorder: true
            source: shadowSource
            radius: Kirigami.Units.largeSpacing * 2
            cached: true
            readonly property bool inView: delegate.x <= listView.contentX + listView.width && delegate.x + delegate.width >= listView.contentX
            visible: inView
        }

        Rectangle {
            id: frame
            anchors {
                fill: parent
            }

            color: delegate.Kirigami.Theme.backgroundColor

            states: [
                State {
                    when: delegate.isCurrent
                    PropertyChanges {
                        target: delegate
                        leftInset: 0
                        rightInset: 0
                        topInset: 0
                        bottomInset: 0
                    }
                    PropertyChanges {
                        target: frame
                        radius: 6
                    }
                    PropertyChanges {
                        target: background.highlight
                        radius: 6
                    }
                },
                State {
                    when: !delegate.isCurrent
                    PropertyChanges {
                        target: delegate
                        leftInset: Kirigami.Units.largeSpacing
                        rightInset: Kirigami.Units.largeSpacing
                        topInset: Kirigami.Units.largeSpacing
                        bottomInset: Kirigami.Units.largeSpacing
                    }
                    PropertyChanges {
                        target: frame
                        radius: 3
                    }
                    PropertyChanges {
                        target: background.highlight
                        radius: 3
                    }
                }
            ]

            transitions: Transition {
                ParallelAnimation {
                    NumberAnimation {
                        property: "leftInset"
                        duration: Kirigami.Units.longDuration
                        easing.type: Easing.InOutQuad
                    }
                    NumberAnimation {
                        property: "rightInset"
                        duration: Kirigami.Units.longDuration
                        easing.type: Easing.InOutQuad
                    }
                    NumberAnimation {
                        property: "topInset"
                        duration: Kirigami.Units.longDuration
                        easing.type: Easing.InOutQuad
                    }
                    NumberAnimation {
                        property: "bottomInset"
                        duration: Kirigami.Units.longDuration
                        easing.type: Easing.InOutQuad
                    }
                    NumberAnimation {
                        property: "radius"
                        duration: Kirigami.Units.longDuration
                        easing.type: Easing.InOutQuad
                    }
                }
            }
        }
    }
}
