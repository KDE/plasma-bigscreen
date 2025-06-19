/*
    SPDX-FileCopyrightText: 2019 Aditya Mehra <aix.m@outlook.com>
    SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import QtQuick.Effects

import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami
import org.kde.bigscreen as Bigscreen

QQC2.ItemDelegate {
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
        listView && listView.currentIndex == index && activeFocus && !listView.moving
    }

    highlighted: isCurrent
    property int shadowSize: 16
    property int borderSize: Kirigami.Units.smallSpacing
    property int baseRadius: Kirigami.Units.cornerRadius

    z: isCurrent ? 2 : 0

    onClicked: {
        listView.forceActiveFocus()
        listView.currentIndex = index
    }

    leftPadding: Kirigami.Units.gridUnit
    topPadding: Kirigami.Units.gridUnit
    rightPadding: Kirigami.Units.gridUnit
    bottomPadding: Kirigami.Units.gridUnit

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
            }
            color: "transparent"
            border {
                width: delegate.borderSize
                color: delegate.Kirigami.Theme.highlightColor
            }
            opacity: delegate.isCurrent || delegate.highlighted
            Behavior on opacity {
                OpacityAnimator {
                    duration: Kirigami.Units.longDuration/2
                    easing.type: Easing.InOutQuad
                }
            }
        }

        Rectangle {
            id: frame
            anchors.fill: parent
            radius: delegate.baseRadius
            color: delegate.Kirigami.Theme.backgroundColor
            visible: false // Drawn by MultiEffect below

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
                        target: background.highlight.anchors
                        margins: 0
                    }
                    PropertyChanges {
                        target: frame
                        // baseRadius + borderSize preserves the original radius for the visible part of frame
                        radius: delegate.baseRadius + delegate.borderSize
                    }
                    PropertyChanges {
                        target: background.highlight
                        // baseRadius + borderSize preserves the original radius for the visible part of frame
                        radius: delegate.baseRadius + delegate.borderSize
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
                        target: background.highlight.anchors
                        margins: Kirigami.Units.largeSpacing
                    }
                    PropertyChanges {
                        target: frame
                        radius: delegate.baseRadius
                    }
                    PropertyChanges {
                        target: background.highlight
                        radius: delegate.baseRadius
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
                    NumberAnimation {
                        property: "margins"
                        duration: Kirigami.Units.longDuration
                        easing.type: Easing.InOutQuad
                    }
                }
            }
        }

        MultiEffect {
            id: frameShadow

            anchors.fill: frame
            source: frame
            blurMax: delegate.shadowSize
            shadowEnabled: true
            shadowOpacity: 0.6
            shadowColor: 'black'
        }
    }
}
