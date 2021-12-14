/*
    SPDX-FileCopyrightText: 2021 Aditya Mehra <aix.m@outlook.com>
    SPDX-FileCopyrightText: 2013-2017 Jan Grulich <jgrulich@redhat.com>
    SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL
*/

import QtQuick 2.14
import QtQuick.Layouts 1.12
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.kirigami 2.12 as Kirigami

Item {
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
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: Kirigami.Units.largeSpacing
        text: "IP Address Details"
        visible: ipDetails.length > 0 ? 1 : 0
        enabled: ipDetails.length > 0 ? 1 : 0
    }

    Column {
        id: ipAddressBlockColumn
        width: parent.width
        anchors.top: ipAddressesLabel.bottom
        anchors.topMargin: Kirigami.Units.largeSpacing
        visible: ipDetails.length > 0 ? 1 : 0
        enabled: ipDetails.length > 0 ? 1 : 0

        Repeater {
            id: ipAddressBlockRepeater

            property int contentHeight: 0
            property int longestString: 0
            visible: ipDetails.length > 0 ? 1 : 0
            enabled: ipDetails.length > 0 ? 1 : 0

            model: ipDetails.length / 2

            Item {
                anchors {
                    left: parent.left
                    right: parent.right
                }
                height: Math.max(detailNameLabel.height, detailValueLabel.height)

                PlasmaComponents.Label {
                    id: detailNameLabel
                    anchors {
                        left: parent.left
                        leftMargin: Kirigami.Units.largeSpacing
                    }
                    height: paintedHeight
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
                    anchors {
                        left: detailNameLabel.right
                        right: parent.right
                    }
                    height: paintedHeight
                    elide: Text.ElideRight
                    text: ipDetails[(index*2)+1]
                    textFormat: Text.PlainText
                    wrapMode: Text.WrapAnywhere
                }
            }
        }
    }

    Kirigami.Separator {
        id: detailsSept
        anchors.top: ipAddressBlockColumn.bottom
        anchors.topMargin: Kirigami.Units.largeSpacing
        visible: connected
        height: 1
        anchors.left: parent.left
        anchors.leftMargin: Kirigami.Units.largeSpacing
        anchors.right: parent.right
        anchors.rightMargin: Kirigami.Units.largeSpacing
    }

    Kirigami.Heading {
        id: networkInformationLabel
        anchors.top: detailsSept.visible ? detailsSept.bottom : parent.top
        anchors.topMargin: Kirigami.Units.largeSpacing
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: Kirigami.Units.largeSpacing
        text: "Network Information"
        visible: networkDetails.length > 0 ? 1 : 0
        enabled: networkDetails.length > 0 ? 1 : 0
    }

    Column {
        id: networkInformationBlockColumn
        width: parent.width
        anchors.top: networkInformationLabel.bottom
        anchors.topMargin: Kirigami.Units.largeSpacing
        anchors.bottom: parent.bottom
        visible: networkDetails.length > 0 ? 1 : 0
        enabled: networkDetails.length > 0 ? 1 : 0

        Repeater {
            id: networkInformationRepeater

            property int contentHeight: 0
            property int longestString: 0
            visible: networkDetails.length > 0 ? 1 : 0
            enabled: networkDetails.length > 0 ? 1 : 0

            model: networkDetails.length / 2

            Item {
                anchors {
                    left: parent.left
                    right: parent.right
                }
                height: Math.max(detailNameLabel.height, detailValueLabel.height)

                PlasmaComponents.Label {
                    id: detailNameLabel
                    anchors {
                        left: parent.left
                        leftMargin: Kirigami.Units.largeSpacing
                    }
                    height: paintedHeight
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
                    anchors {
                        left: detailNameLabel.right
                        right: parent.right
                    }
                    height: paintedHeight
                    elide: Text.ElideRight
                    text: networkDetails[(index*2)+1]
                    textFormat: Text.PlainText
                    wrapMode: Text.Wrap
                }
            }
        }
    }
}
 
