/*
    SPDX-FileCopyrightText: 2020 Aditya Mehra <aix.m@outlook.com>

    SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL

*/

import QtQuick.Layouts
import QtQuick
import QtQuick.Window
import QtQuick.Controls
import org.kde.plasma.plasma5support as P5Support
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.extras as PlasmaExtras
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import org.kde.bigscreen as Bigscreen
import org.kde.plasma.private.digitalclock

Item {
    id: main
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

    P5Support.DataSource {
        id: dataSource
        engine: "time"
        connectedSources: ["Local"]
        interval: 1000
    }

    Component.onCompleted: {
        tzOffset = new Date().getTimezoneOffset();
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
                color: Kirigami.Theme.textColor
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

            Button {
                id: timeDisplayItemTwo
                Layout.fillWidth: true
                Layout.preferredHeight: Kirigami.Units.gridUnit * 4
                Layout.alignment: Qt.AlignTop | Qt.AlignHCenter
                Layout.topMargin: Kirigami.Units.largeSpacing
                text: i18n("Timezone:") + " " + dataSource.data["Local"]["Timezone"]
                KeyNavigation.up: backBtnSettingsItem
                KeyNavigation.down: timeDisplayItemThree
                onClicked: timeZonePickerSheet.open()
                Keys.onReturnPressed: clicked()
                onActiveFocusChanged: {
                    if(activeFocus){
                        flickContentLayout.makeVisible(timeDisplayItemTwo)
                    }
                }
            }

            Button {
                id: timeDisplayItemThree
                Layout.fillWidth: true
                Layout.preferredHeight: Kirigami.Units.gridUnit * 4
                Layout.alignment: Qt.AlignTop | Qt.AlignHCenter
                Layout.topMargin: Kirigami.Units.largeSpacing
                KeyNavigation.up: timeDisplayItemTwo
                KeyNavigation.down: timeDisplayItemFour
                Keys.onReturnPressed: clicked()
                highlighted: timeDisplayItemThree.activeFocus

                onActiveFocusChanged: {
                    if(activeFocus){
                        flickContentLayout.makeVisible(timeDisplayItemThree)
                    }
                }

                contentItem: Item {
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: Kirigami.Units.largeSpacing

                        Kirigami.Icon {
                            source: "preferences-system-time"
                            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                            Layout.fillHeight: true
                            Layout.preferredWidth: height
                        }

                        Label {
                            text: i18n("Set time automatically")
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignLeft
                        }

                        Item {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                        }
                        
                        Switch {
                            id: ntpCheckBox
                            checked: kcm.useNtp
                            Layout.rightMargin: Kirigami.Units.largeSpacing
                            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                            Layout.fillHeight: true
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
                }

                onClicked: {
                    ntpCheckBox.checked = !ntpCheckBox.checked
                    ntpCheckBox.clicked()
                }
            }

            Button {
                id: timeDisplayItemFour
                Layout.fillWidth: true
                Layout.preferredHeight: Kirigami.Units.gridUnit * 4
                Layout.alignment: Qt.AlignTop | Qt.AlignHCenter
                Layout.topMargin: Kirigami.Units.largeSpacing
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


                contentItem: Item {
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: Kirigami.Units.largeSpacing

                        Kirigami.Icon {
                            source: "clock"
                            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                            Layout.fillHeight: true
                            Layout.preferredWidth: height
                        }

                        Label {
                            text: i18n("Time")
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignLeft
                        }

                        Item {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                        }
                        
                        Label {
                            Layout.rightMargin: Kirigami.Units.largeSpacing
                            Layout.fillHeight: true
                            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignLeft
                            text: {
                                var now = dataSource.data["Local"]["DateTime"];
                                var msUTC = now.getTime() + (now.getTimezoneOffset() * 60000);
                                var currentTime = new Date(msUTC + (dataSource.data["Local"]["Offset"] * 1000));

                                main.currentDate = currentTime
                                return Qt.formatTime(currentTime,"hh:mm");
                            }
                        }
                    }
                }
            }

            Button {
                id: timeDisplayItemFive
                Layout.fillWidth: true
                Layout.preferredHeight: Kirigami.Units.gridUnit * 4
                Layout.alignment: Qt.AlignTop | Qt.AlignHCenter
                Layout.topMargin: Kirigami.Units.largeSpacing
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

                contentItem: Item {
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: Kirigami.Units.largeSpacing

                        Kirigami.Icon {
                            source: "view-calendar"
                            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                            Layout.fillHeight: true
                            Layout.preferredWidth: height
                        }

                        Label {
                            text: i18n("Date")
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignLeft
                        }

                        Item {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                        }
                        
                        Label {
                            Layout.rightMargin: Kirigami.Units.largeSpacing
                            Layout.fillHeight: true
                            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignLeft
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
            icon.name: "arrow-left"
            Layout.alignment: Qt.AlignLeft

            PlasmaExtras.Highlight {
                z: -2
                anchors.fill: parent
                anchors.margins: -Kirigami.Units.gridUnit / 4
                visible: backBtnSettingsItem.activeFocus ? 1 : 0
            }

            Keys.onReturnPressed: {
                clicked()
            }

            onClicked: {
                settingsAreaLoader.opened = false
                settingsAreaLoader.settingsAreaComponent = ""
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
        width: parent.width
        height: parent.height
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
                        icon.name: "arrow-left"
                        Layout.alignment: Qt.AlignLeft
                        KeyNavigation.down: searchBoxItem

                        PlasmaExtras.Highlight {
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
                        placeholderText: i18n("Search City / Region")
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

                    delegate: ItemDelegate {
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
        width: parent.width
        height: parent.height
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
                    icon.name: "arrow-left"
                    Layout.alignment: Qt.AlignLeft
                    KeyNavigation.down: timePicker

                    PlasmaExtras.Highlight {
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

            TimePicker {
                id: timePicker
                enabled: !ntpCheckBox.checked
                Layout.fillWidth: true
                Layout.preferredHeight: parent.height * 0.50

                Component.onCompleted: {
                    var date = new Date(main.currentTime);
                    timePicker.hour = date.getHours();
                    timePicker.minute = date.getMinutes();
                    timePicker.second = date.getSeconds();
                }

                onUserConfiguringChanged: {
                    var date = new Date(main.currentTime)
                    date.setHours(timePicker.hour)
                    date.setMinutes(timePicker.minute)
                    date.setSeconds(timePicker.second)

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
        width: parent.width
        height: parent.height
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
                    icon.name: "arrow-left"
                    Layout.alignment: Qt.AlignLeft
                    KeyNavigation.down: datePicker

                    PlasmaExtras.Highlight {
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

            DatePicker {
                id: datePicker
                enabled: !ntpCheckBox.checked
                Layout.fillWidth: true
                Layout.preferredHeight: parent.height * 0.50

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
