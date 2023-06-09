/*
 *   SPDX-FileCopyrightText: 2011 Marco Martin <mart@kde.org>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.14
import org.kde.kirigami 2.12 as Kirigami

Item {
    id: root
    clip: true
    property int day
    property int month
    property int year

    property bool userConfiguring: visible

    property int fontSize: 14
    property int _margin: Kirigami.Units.gridUnit

    opacity: enabled ? 1.0 : 0.5

    onVisibleChanged: {
        if(visible){
            dayDigit.model = getDaysInMonth()
        }
    }

    onFocusChanged: {
        if(focus) {
            dayDigit.forceActiveFocus()
        }
    }

    function getDaysInMonth() {
        // Here January is 1 based
        //Day 0 is the last day in the previous month
        //return new Date(year, month, 0).getDate();
        // Here January is 0 based
        var dt = new Date(root.year, root.month+1, 0).getDate()
        return dt
    }

    Rectangle {
        color: "transparent"
        border.color: Kirigami.Theme.textColor
        border.width: 1
        anchors.fill: parent
        anchors.margins: Kirigami.Units.largeSpacing

        Row {
            id: clockRow
            spacing: 3
            anchors.fill: parent
            anchors.margins: Kirigami.Units.smallSpacing

            property int day
            property int month
            property int year

            function twoDigitString(number)
            {
                return number < 10 ? "0"+number : number
            }

            Digit {
                id: dayDigit
                currentIndex: ((day - 1) < model) ? day-1 : 1
                KeyNavigation.right: monthDigit
                KeyNavigation.left: backBtnDTItem

                onSelectedIndexChanged: {
                    if (selectedIndex > -1) {
                        day = selectedIndex+1
                    }
                }
                delegate: Text {
                    horizontalAlignment: Text.AlignHCenter
                    width: dayDigit.width
                    property int ownIndex: index
                    text: clockRow.twoDigitString(index+1)
                    color: dayDigit.focus && dayDigit.currentIndex == index ? Kirigami.Theme.linkColor : Kirigami.Theme.textColor
                    font.pointSize: root.fontSize
                    opacity: PathView.itemOpacity
                }
            }
            Kirigami.Separator {
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                }
            }
            Digit {
                id: monthDigit
                model: 12
                currentIndex: month -1
                KeyNavigation.right: yearDigit
                KeyNavigation.left: dayDigit

                onSelectedIndexChanged: {
                    if (selectedIndex > -1) {
                        month = selectedIndex + 1
                    }
                }
                delegate: Text {
                    horizontalAlignment: Text.AlignHCenter
                    width: monthDigit.width
                    property int ownIndex: index
                    property variant months: Array(i18n("Jan"), i18n("Feb"), i18n("Mar"), i18n("Apr"), i18n("May"), i18n("Jun"), i18n("Jul"), i18n("Aug"), i18n("Sep"), i18n("Oct"), i18n("Nov"), i18n("Dec"))
                    text: months[index]
                    font.pointSize: root.fontSize
                    color: monthDigit.focus && monthDigit.currentIndex == index ? Kirigami.Theme.linkColor : Kirigami.Theme.textColor
                    opacity: PathView.itemOpacity
                }
                Text {
                    id: monthPlaceHolder
                    visible: false
                    font.pointSize: root.fontSize
                    text: "0000"
                }
            }
            Kirigami.Separator {
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                }
            }
            Digit {
                id: yearDigit
                //FIXME: yes, this is a tad lame ;)
                model: 3000
                currentIndex: year
                KeyNavigation.left: monthDigit
                KeyNavigation.right: backBtnDTItem

                onSelectedIndexChanged: {
                    if (selectedIndex > -1) {
                        year = selectedIndex
                    }
                }
                Text {
                    id: yearPlaceHolder
                    visible: false
                    font.pointSize: root.fontSize
                    color: yearDigit.focus && yearDigit.currentIndex == index ? Kirigami.Theme.linkColor : Kirigami.Theme.textColor
                    text: "0000"
                }
            }
        }
    }
}
