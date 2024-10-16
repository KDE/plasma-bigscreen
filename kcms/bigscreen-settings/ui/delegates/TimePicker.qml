/*
 *   SPDX-FileCopyrightText: 2021 Aditya Mehra <aix.m@outlook.com>
 *   SPDX-FileCopyrightText: 2011 Marco Martin <mart@kde.org>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Item {
    id: timePicker
    
    property int hour
    property int minute
    property int second
    property bool use12HourFormat: true
    property bool userConfiguring: visible
    opacity: enabled ? 1.0 : 0.5

    RowLayout {
        id: timePickerHeader
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: Kirigami.Units.gridUnit * 3
        spacing: 0

        Rectangle {
            Layout.preferredWidth: hourTumbler.width
            Layout.fillHeight: true
            color: Kirigami.Theme.backgroundColor
            border.color: Kirigami.Theme.disabledTextColor
            border.width: 1

            Label {
                anchors.fill: parent
                text: i18n("Hour")
                color: Kirigami.Theme.textColor
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }

        Rectangle {
            Layout.preferredWidth: minuteTumbler.width
            Layout.fillHeight: true
            color: Kirigami.Theme.backgroundColor
            border.color: Kirigami.Theme.disabledTextColor
            border.width: 1

            Label {
                anchors.fill: parent
                text: i18n("Minute")
                color: Kirigami.Theme.textColor
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }

        Rectangle {
            Layout.preferredWidth: secondTumbler.width
            Layout.fillHeight: true
            color: Kirigami.Theme.backgroundColor
            border.color: Kirigami.Theme.disabledTextColor
            border.width: 1

            Label {
                anchors.fill: parent
                text: i18n("Second")
                color: Kirigami.Theme.textColor
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }

        Rectangle {
            Layout.preferredWidth: ampmTumbler.width
            Layout.fillHeight: true
            color: Kirigami.Theme.backgroundColor
            border.color: Kirigami.Theme.disabledTextColor
            border.width: 1
            visible: use12HourFormat

            Label {
                anchors.fill: parent
                text: i18n("AM/PM")
                color: Kirigami.Theme.textColor
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }
    }

    RowLayout {
        anchors.top: timePickerHeader.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        spacing: 0

        Tumbler {
            id: hourTumbler
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: use12HourFormat ? 12 : 24
            currentIndex: timePicker.hour
            KeyNavigation.right: minuteTumbler
            KeyNavigation.left: secondTumbler

            background: Rectangle {
                color: Kirigami.Theme.backgroundColor
                border.color: hourTumbler.activeFocus ? Kirigami.Theme.highlightColor : Kirigami.Theme.disabledTextColor
                border.width: 1
            }

            delegate: Label {
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                color: hourTumbler.currentIndex == index ? Kirigami.Theme.highlightColor : Kirigami.Theme.textColor
                font.bold: hourTumbler.currentIndex == index
                font.pixelSize: hourTumbler.currentIndex == index ? 24 : 16
                text: use12HourFormat ? (index == 0 ? 12 : index) : index
            }
        }

        Tumbler {
            id: minuteTumbler
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: 60
            currentIndex: timePicker.minute
            KeyNavigation.right: secondTumbler
            KeyNavigation.left: hourTumbler

            background: Rectangle {
                color: Kirigami.Theme.backgroundColor
                border.color: minuteTumbler.activeFocus ? Kirigami.Theme.highlightColor : Kirigami.Theme.disabledTextColor
                border.width: 1
            }

            delegate: Label {
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                color: minuteTumbler.currentIndex == index ? Kirigami.Theme.highlightColor : Kirigami.Theme.textColor
                font.bold: minuteTumbler.currentIndex == index
                font.pixelSize: minuteTumbler.currentIndex == index ? 24 : 16
                text: index
            }
        }

        Tumbler {
            id: secondTumbler
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: 60
            currentIndex: timePicker.second
            KeyNavigation.left: minuteTumbler
            KeyNavigation.right: use12HourFormat ? ampmTumbler : hourTumbler

            background: Rectangle {
                color: Kirigami.Theme.backgroundColor
                border.color: secondTumbler.activeFocus ? Kirigami.Theme.highlightColor : Kirigami.Theme.disabledTextColor
                border.width: 1
            }

            delegate: Label {
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                color: secondTumbler.currentIndex == index ? Kirigami.Theme.highlightColor : Kirigami.Theme.textColor
                font.bold: secondTumbler.currentIndex == index
                font.pixelSize: secondTumbler.currentIndex == index ? 24 : 16
                text: index
            }
        }

        Tumbler {
            id: ampmTumbler
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: ListModel {
                ListElement { text: "AM" }
                ListElement { text: "PM" }
            }
            currentIndex: timePicker.hour >= 12 ? 1 : 0
            visible: use12HourFormat
            KeyNavigation.left: secondTumbler
            KeyNavigation.right: hourTumbler


            background: Rectangle {
                color: Kirigami.Theme.backgroundColor
                border.color: ampmTumbler.activeFocus ? Kirigami.Theme.highlightColor : Kirigami.Theme.disabledTextColor
                border.width: 1
            }

            delegate: Label {
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                color: ampmTumbler.currentIndex == index ? Kirigami.Theme.highlightColor : Kirigami.Theme.textColor
                font.bold: ampmTumbler.currentIndex == index
                font.pixelSize: ampmTumbler.currentIndex == index ? 24 : 16
                text: model.text
            }
        }
    }
}