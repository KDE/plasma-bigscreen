/*
    SPDX-FileCopyrightText: 2020 Aditya Mehra <aix.m@outlook.com>

    SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL

*/

import QtQuick.Layouts 1.14
import QtQuick 2.14
import QtQuick.Window 2.14
import QtQuick.Controls 2.14
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.kirigami 2.12 as Kirigami
import org.kde.kcm 1.2 as KCM
import org.kde.mycroft.bigscreen 1.0 as BigScreen
import "delegates" as Delegates
import org.kde.plasma.private.digitalclock 1.0

Rectangle {
    id: main
    color: Kirigami.Theme.backgroundColor
    property string timeFormat
    property date currentTime
    property date currentDate

    onActiveFocusChanged: {
        if(activeFocus){
            timeDisplayItemTwo.forceActiveFocus()
        }
    }

    Keys.onBackPressed: {
        backBtnSettingsItem.clicked()
    }

    TimeZoneModel {
        id: timeZones
    }

    PlasmaCore.DataSource {
        id: dataSource
        engine: "time"
        connectedSources: "Local"
        interval: 1000
        onDataChanged: {
            var date = new Date(data["Local"]["DateTime"]);
            var hours = date.getHours();
            var minutes = date.getMinutes();
            var seconds = date.getSeconds();
        }
        Component.onCompleted: {
            onDataChanged();
        }
    }

    Component.onCompleted: {
        tzOffset = new Date().getTimezoneOffset();
        dateTimeChanged();
        dataSource.onDataChanged.connect(dateTimeChanged);
    }

    function dateTimeChanged()
    {
        var currentTZOffset = dataSource.data["Local"]["Offset"] / 60;
        if (currentTZOffset !== tzOffset) {
            tzOffset = currentTZOffset;
            Date.timeZoneUpdated();
        }
    }


    Item {
        id: emptyArea
        height: Kirigami.Units.gridUnit * 2
        width: parent.width
        anchors.top: parent.top
    }

    Flickable {
        id: flickContentLayout
        clip: true
        anchors {
            top: emptyArea.bottom
            left: parent.left
            right: parent.right
            bottom: footerAreaSettingsSept.top
            margins: Kirigami.Units.largeSpacing * 2
        }
        contentWidth: width
        contentHeight: colLayoutSettingsItem.implicitHeight

        function makeVisible(item) {
            var startArea = item.mapToItem(contentItem, 0, 0).y
            var endArea = item.height + startArea
            if ( startArea < contentY || startArea > contentY + height || endArea < contentY || endArea > contentY + height) {
                contentY = Math.max(0, Math.min(startArea - height + item.height, contentHeight - height))
            }
        }

        Behavior on contentY {
            NumberAnimation {
                duration: Kirigami.Units.longDuration * 2
                easing.type: Easing.InOutQuad
            }
        }

        ColumnLayout {
            id: colLayoutSettingsItem
            width: parent.width
            anchors.top: parent.top


            Kirigami.Icon {
                id: dIcon
                Layout.alignment: Qt.AlignTop | Qt.AlignHCenter
                Layout.preferredWidth: parent.width
                Layout.preferredHeight: width / 3
                source: "preferences-system-time"
            }

            Kirigami.Heading {
                id: label1
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignTop | Qt.AlignHCenter
                Layout.topMargin: Kirigami.Units.largeSpacing
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                level: 2
                maximumLineCount: 2
                elide: Text.ElideRight
                color: PlasmaCore.ColorScope.textColor
                text: "Adjust Date & Time Settings"
            }

            Kirigami.Separator {
                id: lblSept
                Layout.alignment: Qt.AlignTop | Qt.AlignHCenter
                Layout.topMargin: Kirigami.Units.largeSpacing
                Layout.preferredHeight: 1
                Layout.fillWidth: true
            }

            Kirigami.ListSectionHeader {
                id: timeDisplaySectionHeader
                Layout.alignment: Qt.AlignTop
                Layout.topMargin: Kirigami.Units.largeSpacing
                label: i18n("Time Display")
            }

            Kirigami.BasicListItem {
                id: timeDisplayItemTwo
                Layout.alignment: Qt.AlignTop
                Layout.topMargin: Kirigami.Units.largeSpacing
                label: i18n("Timezone:")
                onClicked: timeZonePickerSheet.open()
                Label {
                    id: timeZoneButton
                    text: dataSource.data["Local"]["Timezone"]
                }
                KeyNavigation.up: backBtnSettingsItem
                KeyNavigation.down: timeDisplayItemThree
                Keys.onReturnPressed: clicked()
                onActiveFocusChanged: {
                    if(activeFocus){
                        flickContentLayout.makeVisible(timeDisplayItemTwo)
                    }
                }
            }

            Kirigami.BasicListItem {
                id: timeDisplayItemThree
                Layout.alignment: Qt.AlignTop
                Layout.topMargin: Kirigami.Units.largeSpacing
                label: i18n("Set time automatically:")
                KeyNavigation.up: timeDisplayItemTwo
                KeyNavigation.down: timeDisplayItemFour
                Keys.onReturnPressed: clicked()
                onActiveFocusChanged: {
                    if(activeFocus){
                        flickContentLayout.makeVisible(timeDisplayItemThree)
                    }
                }

                onClicked: {
                    ntpCheckBox.checked = !ntpCheckBox.checked
                    ntpCheckBox.clicked()
                }

                Switch {
                    id: ntpCheckBox
                    checked: kcm.useNtp
                    onClicked: {
                        kcm.useNtp = checked;
                        if (!checked) {
                            kcm.ntpServer = ""
                            kcm.setCurrentTime(main.currentTime)
                            kcm.setCurrentDate(main.currentDate)
                            kcm.saveTime()
                        }
                    }
                }
            }

            Kirigami.BasicListItem {
                id: timeDisplayItemFour
                Layout.alignment: Qt.AlignTop
                Layout.topMargin: Kirigami.Units.largeSpacing
                label: i18n("Time")
                icon: "clock"
                enabled: !ntpCheckBox.checked
                onClicked: timePickerSheet.open()
                KeyNavigation.up: timeDisplayItemThree
                KeyNavigation.down: timeDisplayItemFive
                Keys.onReturnPressed: clicked()
                onActiveFocusChanged: {
                    if(activeFocus){
                        flickContentLayout.makeVisible(timeDisplayItemFour)
                    }
                }

                Label {
                    text: {
                        // get the time for the given timezone from the dataengine
                        var now = dataSource.data["Local"]["DateTime"];
                        // get current UTC time
                        var msUTC = now.getTime() + (now.getTimezoneOffset() * 60000);
                        // add the dataengine TZ offset to it
                        var currentTime = new Date(msUTC + (dataSource.data["Local"]["Offset"] * 1000));

                        main.currentDate = currentTime
                        return Qt.formatTime(currentTime,"hh:mm");
                    }
                }
            }

            Kirigami.BasicListItem {
                id: timeDisplayItemFive
                Layout.alignment: Qt.AlignTop
                Layout.topMargin: Kirigami.Units.largeSpacing
                label: i18n("Date")
                icon: "view-calendar"
                enabled: !ntpCheckBox.checked
                onClicked: datePickerSheet.open()
                KeyNavigation.up: timeDisplayItemFour
                KeyNavigation.down: backBtnSettingsItem
                Keys.onReturnPressed: clicked()
                onActiveFocusChanged: {
                    if(activeFocus){
                        flickContentLayout.makeVisible(timeDisplayItemFive)
                    }
                }

                Label {
                    text: {
                        // get the time for the given timezone from the dataengine
                        var now = dataSource.data["Local"]["DateTime"];
                        // get current UTC time
                        var msUTC = now.getTime() + (now.getTimezoneOffset() * 60000);
                        // add the dataengine TZ offset to it
                        var currentTime = new Date(msUTC + (dataSource.data["Local"]["Offset"] * 1000));

                        main.currentDate = currentTime
                        return Qt.formatDate(currentTime,"dd.MM.yyyy");
                    }
                }
            }
        }
    }

    Kirigami.Separator {
        id: footerAreaSettingsSept
        anchors.bottom: footerAreaSettingsItem.top
        anchors.bottomMargin: Kirigami.Units.largeSpacing
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: Kirigami.Units.largeSpacing * 2
        anchors.rightMargin: Kirigami.Units.largeSpacing * 2
        height: 1
    }

    RowLayout {
        id: footerAreaSettingsItem
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: Kirigami.Units.largeSpacing * 2
        height: Kirigami.Units.gridUnit * 2

        PlasmaComponents.Button {
            id: backBtnSettingsItem
            iconSource: "arrow-left"
            Layout.alignment: Qt.AlignLeft

            PlasmaComponents.Highlight {
                z: -2
                anchors.fill: parent
                anchors.margins: -Kirigami.Units.gridUnit / 4
                visible: backBtnSettingsItem.activeFocus ? 1 : 0
            }

            Keys.onReturnPressed: {
                clicked()
            }

            onClicked: {
                deviceTimeSettingsArea.opened = false
                timeDateSettingsDelegate.forceActiveFocus()
            }
        }

        Label {
            id: backbtnlabelHeading
            text: i18n("Press the [←] Back button to return to appearance settings")
            wrapMode: Text.WordWrap
            maximumLineCount: 2
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignRight
        }
    }

    Popup {
        id: timeZonePickerSheet
        width: parent.width / 2
        height: parent.height / 1.25
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        parent: parent.parent

        onOpenedChanged: {
            if(opened){
                searchBoxItem.forceActiveFocus()
            }
        }

        Keys.onBackPressed: {
            backBtnTZPItem.clicked()
        }

        FocusScope {
            anchors.fill: parent

            ColumnLayout {
                anchors.fill: parent

                RowLayout {
                    id: timeZonePickerSheetFooterItem
                    Layout.fillWidth: true
                    Layout.preferredHeight: parent.height * 0.10


                    PlasmaComponents.Button {
                        id: backBtnTZPItem
                        iconSource: "arrow-left"
                        Layout.alignment: Qt.AlignLeft
                        KeyNavigation.down: searchBoxItem

                        PlasmaComponents.Highlight {
                            z: -2
                            anchors.fill: parent
                            anchors.margins: -Kirigami.Units.gridUnit / 4
                            visible: backBtnTZPItem.activeFocus ? 1 : 0
                        }

                        Keys.onReturnPressed: {
                            clicked()
                        }

                        onClicked: {
                            timeZonePickerSheet.close()
                            timeDisplayItemTwo.forceActiveFocus()
                        }
                    }

                    Label {
                        id: backbtnlabelTZPHeading
                        text: i18n("Press the [←] Back button to save configuration and return to settings")
                        wrapMode: Text.WordWrap
                        maximumLineCount: 2
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignRight
                    }
                }

                Rectangle {
                    id: searchBoxItem
                    color: "transparent"
                    Layout.fillWidth: true
                    Layout.preferredHeight: parent.height * 0.10
                    border.color: Kirigami.Theme.linkColor
                    border.width: searchBoxItem.focus ? 1 : 0
                    KeyNavigation.up: backBtnTZPItem
                    KeyNavigation.down: listView
                    Keys.onReturnPressed: searchField.forceActiveFocus()

                    Kirigami.SearchField {
                        id: searchField
                        anchors.fill: parent
                        placeholderText: "Search City / Region"
                    }
                }

                ListView {
                    id: listView
                    clip: true
                    focus: false

                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    model: TimeZoneFilterProxy {
                        sourceModel: timeZones
                        filterString: searchField.text
                    }

                    delegate: Kirigami.BasicListItem {
                        width: parent.width
                        text: model.timeZoneId == "Local" ? i18n("Your local timezone is %1", city) : i18n("%1, %2", city, region)
                        enabled: model.timeZoneId != "Local" ? 1 : 0

                        Keys.onReturnPressed: clicked()
                        onClicked: {
                            kcm.saveTimeZone(model.timeZoneId)
                        }
                        onFocusChanged: {
                            if(focus && model.timeZoneId == "Local") {
                                listView.currentIndex = index + 1
                            }
                        }
                    }

                    Keys.onUpPressed: {
                        if(listView.currentIndex == 0 || listView.currentIndex == 1) {
                            searchBoxItem.forceActiveFocus()
                            listView.focus = false
                        } else {
                            listView.decrementCurrentIndex()
                        }
                    }
                }
            }
        }
    }


   Popup {
        id: timePickerSheet
        width: parent.width / 2
        height: parent.height / 2
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        parent: parent.parent

        onOpenedChanged: {
            if(opened){
                timePicker.forceActiveFocus()
            }
        }

        onClosed: {
            timeDisplayItemThree.forceActiveFocus()
        }

        Keys.onBackPressed: {
            backBtnTPItem.clicked()
        }

        ColumnLayout {
            anchors.fill: parent

            RowLayout {
                id: timePickerSheetFooterItem
                Layout.fillWidth: true
                Layout.preferredHeight: parent.height * 0.10


                PlasmaComponents.Button {
                    id: backBtnTPItem
                    iconSource: "arrow-left"
                    Layout.alignment: Qt.AlignLeft
                    KeyNavigation.down: timePicker

                    PlasmaComponents.Highlight {
                        z: -2
                        anchors.fill: parent
                        anchors.margins: -Kirigami.Units.gridUnit / 4
                        visible: backBtnTPItem.activeFocus ? 1 : 0
                    }

                    Keys.onReturnPressed: {
                        clicked()
                    }

                    onClicked: {
                        timePickerSheet.close()
                        timeDisplayItemThree.forceActiveFocus()
                    }
                }

                Label {
                    id: backbtnlabelTPHeading
                    text: i18n("Press the [←] Back button to save configuration and return to settings")
                    wrapMode: Text.WordWrap
                    maximumLineCount: 2
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignRight
                }
            }

            Delegates.TimePicker {
                id: timePicker
                enabled: !ntpCheckBox.checked
                Layout.fillWidth: true
                Layout.fillHeight: true

                Component.onCompleted: {
                    var date = new Date(main.currentTime);
                    timePicker.hours = date.getHours();
                    timePicker.minutes = date.getMinutes();
                    timePicker.seconds = date.getSeconds();
                }

                onUserConfiguringChanged: {
                    var date = new Date(main.currentTime)
                    date.setHours(timePicker.hours)
                    date.setMinutes(timePicker.minutes)
                    date.setSeconds(timePicker.seconds)

                    kcm.setCurrentTime(date)
                    kcm.setCurrentDate(date)
                    kcm.saveTime()
                }
            }

            Keys.onReturnPressed: {
                timePickerSheet.close()
                timeDisplayItemThree.forceActiveFocus()
            }
        }
    }

    Popup {
        id: datePickerSheet
        width: parent.width / 2
        height: parent.height / 2
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        parent: parent.parent

        onOpenedChanged: {
            if(opened){
                datePicker.forceActiveFocus()
            }
        }

        onClosed: {
            timeDisplayItemFour.forceActiveFocus()
        }


        Keys.onBackPressed: {
            backBtnDTItem.clicked()
        }

        ColumnLayout {
        anchors.fill: parent

            RowLayout {
                id: datePickerSheetFooterItem
                Layout.fillWidth: true
                Layout.preferredHeight: parent.height * 0.10


                PlasmaComponents.Button {
                    id: backBtnDTItem
                    iconSource: "arrow-left"
                    Layout.alignment: Qt.AlignLeft
                    KeyNavigation.down: datePicker

                    PlasmaComponents.Highlight {
                        z: -2
                        anchors.fill: parent
                        anchors.margins: -Kirigami.Units.gridUnit / 4
                        visible: backBtnDTItem.activeFocus ? 1 : 0
                    }

                    Keys.onReturnPressed: {
                        clicked()
                    }

                    onClicked: {
                        datePickerSheet.close()
                        timeDisplayItemFour.forceActiveFocus()
                    }
                }

                Label {
                    id: backbtnlabelDTHeading
                    text: i18n("Press the [←] Back button to save configuration and return to settings")
                    wrapMode: Text.WordWrap
                    maximumLineCount: 2
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignRight
                }
            }

            Delegates.DatePicker {
                id: datePicker
                enabled: !ntpCheckBox.checked
                Layout.fillWidth: true
                Layout.fillHeight: true

                Component.onCompleted: {
                    var date = new Date(main.currentDate)
                    datePicker.day = date.getDate()
                    datePicker.month = date.getMonth()+1
                    datePicker.year = date.getFullYear()
                }

                onUserConfiguringChanged: {
                    var date = new Date(main.currentDate)
                    date.setDate(datePicker.day)
                    date.setMonth(datePicker.month)
                    date.setFullYear(datePicker.year)

                    kcm.setCurrentTime(date)
                    kcm.setCurrentDate(date)
                    kcm.saveTime()
                }

                Keys.onReturnPressed: {
                    datePickerSheet.close()
                    timeDisplayItemFour.forceActiveFocus()
                }
            }
        }
    }
}
