/*
    SPDX-FileCopyrightText: 2024 Aditya Mehra <aix.m@outlook.com>
    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.4
import org.kde.kirigami as Kirigami

Item {
    id: datePicker

    property int year
    property int month
    property int day
    property bool userConfiguring: visible

    opacity: enabled ? 1.0 : 0.5

    RowLayout {
        id: datePickerHeader
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: Kirigami.Units.gridUnit * 3
        spacing: 0

        Rectangle {
            Layout.preferredWidth: yearTumbler.width
            Layout.fillHeight: true
            color: Kirigami.Theme.backgroundColor
            border.color: Kirigami.Theme.disabledTextColor
            border.width: 1

            Label {
                anchors.fill: parent
                text: i18n("Year")
                color: Kirigami.Theme.textColor
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }

        Rectangle {
            Layout.preferredWidth: monthTumbler.width
            Layout.fillHeight: true
            color: Kirigami.Theme.backgroundColor
            border.color: Kirigami.Theme.disabledTextColor
            border.width: 1

            Label {
                anchors.fill: parent
                text: i18n("Month")
                color: Kirigami.Theme.textColor
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }

        Rectangle {
            Layout.preferredWidth: dayTumbler.width
            Layout.fillHeight: true
            color: Kirigami.Theme.backgroundColor
            border.color: Kirigami.Theme.disabledTextColor
            border.width: 1

            Label {
                anchors.fill: parent
                text: i18n("Day")
                color: Kirigami.Theme.textColor
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }
    }

    RowLayout {
        anchors.top: datePickerHeader.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        spacing: 0

        Tumbler {
            id: yearTumbler
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: 2100
            currentIndex: year - 2000
            KeyNavigation.right: monthTumbler
            KeyNavigation.left: parent

            background: Rectangle {
                color: Kirigami.Theme.backgroundColor
                border.color: yearTumbler.activeFocus ? Kirigami.Theme.highlightColor : Kirigami.Theme.disabledTextColor
                border.width: 1
            }

            delegate: Label {
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                color: yearTumbler.currentIndex == index ? Kirigami.Theme.highlightColor : Kirigami.Theme.textColor
                font.bold: yearTumbler.currentIndex == index
                font.pixelSize: yearTumbler.currentIndex == index ? 24 : 16
                text: 2000 + index
            }
        }

        Tumbler {
            id: monthTumbler
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: 12  // Months are 0-indexed
            currentIndex: month
            KeyNavigation.right: dayTumbler
            KeyNavigation.left: yearTumbler

            background: Rectangle {
                color: Kirigami.Theme.backgroundColor
                border.color: monthTumbler.activeFocus ? Kirigami.Theme.highlightColor : Kirigami.Theme.disabledTextColor
                border.width: 1
            }

            delegate: Label {
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                color: monthTumbler.currentIndex == index ? Kirigami.Theme.highlightColor : Kirigami.Theme.textColor
                font.bold: monthTumbler.currentIndex == index
                font.pixelSize: monthTumbler.currentIndex == index ? 24 : 16
                text: i18n(Qt.locale().monthName(index))
            }
        }

        Tumbler {
            id: dayTumbler
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: 31  // Maximum days in a month
            currentIndex: day - 1
            KeyNavigation.right: yearTumbler
            KeyNavigation.left: monthTumbler

            background: Rectangle {
                color: Kirigami.Theme.backgroundColor
                border.color: dayTumbler.activeFocus ? Kirigami.Theme.highlightColor : Kirigami.Theme.disabledTextColor
                border.width: 1
            }

            delegate: Label {
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                color: dayTumbler.currentIndex == index ? Kirigami.Theme.highlightColor : Kirigami.Theme.textColor
                font.bold: dayTumbler.currentIndex == index
                font.pixelSize: dayTumbler.currentIndex == index ? 24 : 16
                text: index + 1
            }
        }
    }
}