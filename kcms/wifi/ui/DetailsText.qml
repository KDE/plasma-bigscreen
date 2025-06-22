/*
    SPDX-FileCopyrightText: 2021 Aditya Mehra <aix.m@outlook.com>
    SPDX-FileCopyrightText: 2013-2017 Jan Grulich <jgrulich@redhat.com>
    SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
    SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL
*/

import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami

ColumnLayout {
    property bool connected
    property var connectionType
    property var details: []
    property var ipDetails: []
    property var networkDetails: []

    onDetailsChanged: {
        if(connected){
            var detailLength = details.length
            ipDetails = details.slice(0, 8);
            networkDetails = details.slice(8, detailLength)
        } else {
            networkDetails = details
        }
    }

    Kirigami.Heading {
        id: ipAddressesLabel
        Layout.fillWidth: true
        text: i18n("IP Address Details")
        visible: ipDetails.length > 0 ? 1 : 0
        enabled: ipDetails.length > 0 ? 1 : 0
    }

    ColumnLayout {
        id: ipAddressBlockColumn
        Layout.fillWidth: true
        Layout.topMargin: Kirigami.Units.largeSPacing
        visible: ipDetails.length > 0 ? 1 : 0
        enabled: ipDetails.length > 0 ? 1 : 0

        Repeater {
            id: ipAddressBlockRepeater

            property int contentHeight: 0
            property int longestString: 0
            visible: ipDetails.length > 0 ? 1 : 0
            enabled: ipDetails.length > 0 ? 1 : 0

            model: ipDetails.length / 2

            delegate: RowLayout {
                Layout.fillWidth: true

                PlasmaComponents.Label {
                    id: detailNameLabel
                    Layout.fillWidth: true
                    Layout.leftMargin: Kirigami.Units.largeSpacing
                    horizontalAlignment: Text.AlignLeft
                    text: ipDetails[index*2] + ": "

                    Component.onCompleted: {
                        if (paintedWidth > ipAddressBlockRepeater.longestString) {
                            ipAddressBlockRepeater.longestString = paintedWidth
                        }
                    }
                }

                PlasmaComponents.Label {
                    id: detailValueLabel
                    elide: Text.ElideRight
                    text: ipDetails[(index*2)+1]
                    textFormat: Text.PlainText
                    wrapMode: Text.WrapAnywhere
                }
            }
        }
    }

    Kirigami.Heading {
        id: networkInformationLabel
        Layout.fillWidth: true
        text: "Network Information"
        visible: networkDetails.length > 0 ? 1 : 0
        enabled: networkDetails.length > 0 ? 1 : 0
    }

    ColumnLayout {
        id: networkInformationBlockColumn
        Layout.fillWidth: true
        Layout.topMargin: Kirigami.Units.largeSpacing
        visible: networkDetails.length > 0 ? 1 : 0
        enabled: networkDetails.length > 0 ? 1 : 0

        Repeater {
            id: networkInformationRepeater

            property int contentHeight: 0
            property int longestString: 0
            visible: networkDetails.length > 0 ? 1 : 0
            enabled: networkDetails.length > 0 ? 1 : 0

            model: networkDetails.length / 2

            delegate: RowLayout {
                Layout.fillWidth: true

                PlasmaComponents.Label {
                    id: detailNameLabel
                    Layout.fillWidth: true
                    Layout.leftMargin: Kirigami.Units.largeSpacing
                    horizontalAlignment: Text.AlignRight
                    text: networkDetails[index*2] + ": "

                    Component.onCompleted: {
                        if (paintedWidth > networkInformationRepeater.longestString) {
                            networkInformationRepeater.longestString = paintedWidth
                        }
                    }
                }

                PlasmaComponents.Label {
                    id: detailValueLabel
                    elide: Text.ElideRight
                    text: networkDetails[(index*2)+1]
                    textFormat: Text.PlainText
                    wrapMode: Text.Wrap
                }
            }
        }
    }
}

