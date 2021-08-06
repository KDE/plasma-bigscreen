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
    clip: true

    //////// API
    property alias hours: clockRow.hours
    property alias minutes: clockRow.minutes
    property alias seconds: clockRow.seconds

    property bool userConfiguring: visible
    property bool twentyFour: true

    property int fontSize: 14
    property int _margin: Kirigami.Units.gridUnit

    property string timeString: clockRow.twoDigitString(hours) + ":" + clockRow.twoDigitString(minutes) + ":" +  clockRow.twoDigitString(seconds)

    opacity: enabled ? 1.0 : 0.5

    onFocusChanged: {
        if(focus) {
            hoursDigit.forceActiveFocus()
        }
    }

    Behavior on width {
        SequentialAnimation {
            PauseAnimation {
                duration: 250
            }
            NumberAnimation {
                duration: 250
                easing.type: Easing.InOutQuad
            }
        }
    }

    Rectangle {
        color: "transparent"
        border.color: Kirigami.Theme.textColor
        border.width: 1
        anchors.fill: parent
        anchors.margins: Kirigami.Units.largeSpacing

        Row {
            id: clockRow
            anchors.fill: parent
            anchors.margins: Kirigami.Units.smallSpacing

            property int hours
            property int minutes
            property int seconds

            function twoDigitString(number)
            {
                return number < 10 ? "0"+number : number
            }

            Digit {
                id: hoursDigit
                model: root.twentyFour ? 24 : 12
                currentIndex: root.twentyFour || hours < 12 ? hours : hours - 12
                KeyNavigation.right: minutesDigit
                KeyNavigation.left: backBtnTPItem
                delegate: Text {
                    horizontalAlignment: Text.AlignHCenter
                    width: hoursDigit.width
                    property int ownIndex: index
                    text: (!root.twentyFour && index == 0) ? "12" : clockRow.twoDigitString(index)
                    font.pointSize: root.fontSize
                    color: hoursDigit.focus && hoursDigit.currentIndex == index ? Kirigami.Theme.linkColor : Kirigami.Theme.textColor
                    opacity: PathView.itemOpacity
                }
                onSelectedIndexChanged: {
                    if (selectedIndex > -1) {
                        if (root.twentyFour ||
                            meridiaeDigit.isAm) {
                            hours = selectedIndex
                        } else {
                            hours = selectedIndex + 12
                        }
                    }
                }
            }
            Kirigami.Separator {
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                }
            }
            Digit {
                id: minutesDigit
                model: 60
                currentIndex: minutes
                KeyNavigation.right: secondsDigit
                KeyNavigation.left: hoursDigit
                onSelectedIndexChanged: {
                    if (selectedIndex > -1) {
                        minutes = selectedIndex
                    }
                }
            }
            Kirigami.Separator {
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                }
            }
            Digit {
                id: secondsDigit
                model: 60
                currentIndex: seconds
                KeyNavigation.right: backBtnTPItem
                KeyNavigation.left: minutesDigit
                onSelectedIndexChanged: {
                    if (selectedIndex > -1) {
                        seconds = selectedIndex
                    }
                }
            }
            Kirigami.Separator {
                opacity: meridiaeDigit.opacity == 0 ? 0 : 1

                anchors {
                    top: parent.top
                    bottom: parent.bottom
                }
                Behavior on opacity {
                    NumberAnimation {
                        duration: 250
                        easing.type: Easing.InOutQuad
                    }
                }
            }
            Digit {
                id: meridiaeDigit
                visible: opacity != 0
                opacity: root.twentyFour ? 0 : 1
                property bool isAm: (selectedIndex > -1) ? (selectedIndex < 1) : (currentIndex < 1)
                model: ListModel {
                    ListElement {
                        meridiae: "AM"
                    }
                    ListElement {
                        meridiae: "PM"
                    }
                }
                delegate: Text {
                    width: meridiaeDigit.width
                    horizontalAlignment: Text.AlignLeft
                    property int ownIndex: index
                    text: meridiae
                    color: Kirigami.Theme.textColor
                    font.pointSize: root.fontSize
                    //opacity: PathView.itemOpacity
                }
                currentIndex: hours > 12 ? 1 : 0
                onSelectedIndexChanged: {
                    if (selectedIndex > -1) {
                        //AM
                        if (selectedIndex == 0) {
                            hours -= 12
                        //PM
                        } else {
                            hours += 12
                        }
                    }
                }
                width: meridiaePlaceHolder.width + root._margin
                Text {
                    id: meridiaePlaceHolder
                    visible: false
                    font.pointSize: root.fontSize
                    text: "00"
                }
                Behavior on opacity {
                    NumberAnimation {
                        duration: 250
                        easing.type: Easing.InOutQuad
                    }
                }
            }
        }
    }
}
