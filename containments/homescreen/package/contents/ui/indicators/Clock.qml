// SPDX-FileCopyrightText: 2019 Nicolas Fella <nicolas.fella@gmx.de>
// SPDX-FileCopyrightText: 2020-2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import QtQml

import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PC3
import org.kde.plasma.clock

Item {
    id: root
    implicitHeight: clockColumn.visible ? clockColumn.implicitHeight : clockRow.implicitHeight
    implicitWidth: clockColumn.visible ? clockColumn.implicitWidth : clockRow.implicitWidth

    // Expose value that doesn't animate
    readonly property real clockBigHeight: clockColumn.implicitHeight

    // TODO whether to show am/pm from locale?
    property var locale: Qt.locale()

    property string timeString
    property string dateString

    Clock {
        id: clock
        trackSeconds: false
    }

    function updateClock ()
    {
        // Time only, locale-aware (24h vs am/pm, separators, etc.)
        timeString = locale.toString(
            clock.dateTime,
            locale.timeFormat(Locale.ShortFormat)
        )

        // Date only, long form, fully translated
        dateString = locale.toString(
            clock.dateTime,
            locale.dateFormat(Locale.LongFormat)
        )
    }

    Component.onCompleted: updateClock(); // update right at startup

    // update clock when libclock ticks
    Connections {
        target: clock
        function onDateTimeChanged() {
            updateClock();
        }
    }

    // update locale if needed
    Connections {
        target: Qt.application
        function onLocaleChanged() {
            locale = Qt.locale();
            updateClock();
        }
    }

    state: "column"
    states: [
        State {
            name: "column"
            PropertyChanges { target: clockColumn; opacity: 1 }
            PropertyChanges { target: clockRow; opacity: 0 }
        },
        State {
            name: "row"
            PropertyChanges { target: clockColumn; opacity: 0 }
            PropertyChanges { target: clockRow; opacity: 1 }
        }
    ]

    transitions: [
        Transition {
            to: "column"
            SequentialAnimation {
                PropertyAnimation { target: clockRow; property: 'opacity'; duration: 200 }
                PropertyAnimation { target: clockColumn; property: 'opacity'; duration: 200 }
            }
        },
        Transition {
            to: "row"
            SequentialAnimation {
                PropertyAnimation { target: clockColumn; property: 'opacity'; duration: 200 }
                PropertyAnimation { target: clockRow; property: 'opacity'; duration: 200 }
            }
        }
    ]

    RowLayout {
        id: clockRow
        spacing: Kirigami.Units.gridUnit
        visible: opacity > 0

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        PC3.Label {
            id: rowTimeLabel
            color: "white"
            renderType: Text.NativeRendering
            font.weight: Font.ExtraBold
            font.pointSize: 24

            text: root.timeString
        }

        PC3.Label {
            id: rowDateLabel
            color: "white"
            font.pointSize: 22

            text: root.dateString
        }

        Item {
            Layout.fillWidth: true
        }
    }

    ColumnLayout {
        id: clockColumn
        spacing: Kirigami.Units.largeSpacing
        visible: opacity > 0

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        PC3.Label {
            id: columnTimeLabel
            color: "white"
            renderType: Text.NativeRendering
            font.weight: Font.ExtraLight
            font.pointSize: 72
            font.kerning: false
            font.letterSpacing: 3
            horizontalAlignment: Text.AlignLeft

            text: root.timeString
        }

        PC3.Label {
            id: columnDateLabel
            color: "white"
            renderType: Text.NativeRendering
            font.weight: Font.ExtraBold
            font.pointSize: 22
            horizontalAlignment: Text.AlignLeft

            // HACK: columnTimeLabel is of a large font size, so the internal font padding with thin
            //       letters (ex. 1) can cause this label to look misaligned (since they are both
            //       left-aligned). Adjust our left margin to account for this.
            Layout.leftMargin: columnTimeLabel.text.startsWith('1') ? Kirigami.Units.largeSpacing : 0

            text: root.dateString
        }
    }
}
