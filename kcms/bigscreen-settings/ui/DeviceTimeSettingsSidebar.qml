/*
    SPDX-FileCopyrightText: 2019 Aditya Mehra <aix.m@outlook.com>
    SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>

    SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL

*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Window
import QtQuick.Controls as QQC2

import org.kde.plasma.plasma5support as P5Support
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import org.kde.bigscreen as Bigscreen
import org.kde.plasma.private.digitalclock

Bigscreen.SidebarOverlay {
    id: root

    property string timeFormat
    property date currentTime: dataSource.data["Local"]["DateTime"];
    property date tzAdjustedCurrentTime: {
        // get the time for the given timezone from the dataengine
        var now = currentTime;
        // get current UTC time
        var msUTC = now.getTime() + (now.getTimezoneOffset() * 60000);
        // add the dataengine TZ offset to it
        return new Date(msUTC + (dataSource.data["Local"]["Offset"] * 1000));
    }
    property var tzOffset

    openFocusItem: tzDelegate

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

    function dateTimeChanged() {
        var currentTZOffset = dataSource.data["Local"]["Offset"] / 60;
        if (currentTZOffset !== tzOffset) {
            tzOffset = currentTZOffset;
            Date.timeZoneUpdated();
        }
    }

    header: Bigscreen.SidebarOverlayHeader {
        iconSource: "preferences-system-time"
        title: i18n("Adjust Date & Time Settings")
    }

    content: ColumnLayout {
        Keys.onLeftPressed: root.close();
        Keys.onBackPressed: root.close();

        Bigscreen.ButtonDelegate {
            id: tzDelegate
            text: i18n("Timezone")
            description: dataSource.data["Local"]["Timezone"]

            KeyNavigation.down: automaticTimeDelegate

            onClicked: timeZonePickerSheet.open()
        }

        Bigscreen.SwitchDelegate {
            id: automaticTimeDelegate
            checked: kcm.useNtp
            icon.name: 'preferences-system-time'
            text: i18n("Set time automatically")

            KeyNavigation.up: tzDelegate
            KeyNavigation.down: timeDelegate

            onClicked: {
                kcm.useNtp = checked;
                if (!checked) {
                    kcm.ntpServer = "";
                    kcm.saveTime();
                }
            }
        }

        Bigscreen.ButtonDelegate {
            id: timeDelegate
            enabled: !automaticTimeDelegate.checked
            icon.name: 'clock'
            text: i18n('Time')
            description: Qt.formatTime(root.currentTime, "hh:mm");

            KeyNavigation.up: automaticTimeDelegate
            KeyNavigation.down: dateDelegate

            onClicked: timePickerSheet.open()
        }

        Bigscreen.ButtonDelegate {
            id: dateDelegate
            enabled: !automaticTimeDelegate.checked
            icon.name: 'view-calendar'
            text: i18n('Date')
            description: Qt.formatDate(root.currentTime,"dd.MM.yyyy");

            KeyNavigation.up: timeDelegate

            onClicked: datePickerSheet.open()
        }

        Item { Layout.fillHeight: true }
    }

    QQC2.Popup {
        id: timeZonePickerSheet
        width: parent.width
        height: parent.height

        onOpened: backBtnTZPItem.forceActiveFocus()
        onClosed: tzDelegate.forceActiveFocus()

        FocusScope {
            anchors.fill: parent

            ColumnLayout {
                spacing: 0
                anchors.fill: parent

                Bigscreen.Button {
                    id: backBtnTZPItem
                    icon.name: "go-previous-view"
                    text: i18n('Back')
                    Layout.bottomMargin: Kirigami.Units.largeSpacing
                    KeyNavigation.down: searchField

                    onClicked: {
                        timeZonePickerSheet.close()
                        tzDelegate.forceActiveFocus()
                    }
                }

                Bigscreen.TextField {
                    id: searchField
                    Layout.bottomMargin: Kirigami.Units.largeSpacing
                    Layout.fillWidth: true

                    KeyNavigation.up: backBtnTZPItem
                    KeyNavigation.down: listView
                    Keys.onReturnPressed: searchField.forceActiveFocus()

                    placeholderText: i18n("Search City / Region")
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

                    delegate: Bigscreen.ButtonDelegate {
                        raisedBackground: false
                        width: listView.width
                        text: model.timeZoneId == "Local" ? i18n("Your local timezone is %1", city) : i18n("%1, %2", city, region)
                        enabled: model.timeZoneId != "Local" ? 1 : 0

                        onClicked: kcm.saveTimeZone(model.timeZoneId)
                        onFocusChanged: {
                            if (focus && model.timeZoneId == "Local") {
                                listView.currentIndex = index + 1
                            }
                        }
                    }

                    Keys.onUpPressed: {
                        if (listView.currentIndex == 0 || listView.currentIndex == 1) {
                            searchField.forceActiveFocus()
                            listView.focus = false
                        } else {
                            listView.decrementCurrentIndex()
                        }
                    }
                }
            }
        }
    }


   QQC2.Popup {
        id: timePickerSheet
        width: parent.width
        height: parent.height

        onOpened: backBtnTPItem.forceActiveFocus()
        onClosed: timeDelegate.forceActiveFocus()

        ColumnLayout {
            anchors.fill: parent

            Bigscreen.Button {
                id: backBtnTPItem
                icon.name: "go-previous-view"
                text: i18n('Back')
                KeyNavigation.down: timePicker

                onClicked: {
                    timePickerSheet.close()
                    timeDelegate.forceActiveFocus()
                }
            }

            TimePicker {
                id: timePicker
                enabled: !automaticTimeDelegate.checked
                Layout.fillWidth: true
                Layout.preferredHeight: parent.height * 0.50

                Component.onCompleted: {
                    var date = new Date(root.currentTime);
                    timePicker.hour = date.getHours();
                    timePicker.minute = date.getMinutes();
                    timePicker.second = date.getSeconds();
                }

                onUserConfiguringChanged: {
                    var date = new Date(root.currentTime)
                    date.setHours(timePicker.hour)
                    date.setMinutes(timePicker.minute)
                    date.setSeconds(timePicker.second)

                    kcm.setCurrentTime(date)
                    kcm.setCurrentDate(date)
                    kcm.saveTime()
                }
            }
        }
    }

    QQC2.Popup {
        id: datePickerSheet
        width: parent.width
        height: parent.height

        onOpened: backBtnDTItem.forceActiveFocus()
        onClosed: dateDelegate.forceActiveFocus()

        ColumnLayout {
            anchors.fill: parent

            Bigscreen.Button {
                id: backBtnDTItem
                icon.name: "go-previous-view"
                text: i18n('Back')
                KeyNavigation.down: datePicker

                onClicked: {
                    datePickerSheet.close()
                    dateDelegate.forceActiveFocus()
                }
            }

            DatePicker {
                id: datePicker
                enabled: !automaticTimeDelegate.checked
                Layout.fillWidth: true
                Layout.preferredHeight: parent.height * 0.50

                Component.onCompleted: {
                    var date = new Date(root.currentTime)
                    datePicker.day = date.getDate()
                    datePicker.month = date.getMonth()+1
                    datePicker.year = date.getFullYear()
                }

                onUserConfiguringChanged: {
                    var date = new Date(root.currentTime)
                    date.setDate(datePicker.day)
                    date.setMonth(datePicker.month)
                    date.setFullYear(datePicker.year)

                    kcm.setCurrentTime(date)
                    kcm.setCurrentDate(date)
                    kcm.saveTime()
                }
            }
        }
    }
}
