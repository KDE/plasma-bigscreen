/*
    Copyright 2019 Aditya Mehra <aix.m@outlook.com>

    This program is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public License as
    published by the Free Software Foundation; either version 2 of
    the License or (at your option) version 3 or any later version
    accepted by the membership of KDE e.V. (or its successor approved
    by the membership of KDE e.V.), which shall act as a proxy
    defined in Section 14 of version 3 of the license.
  
    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.
    
    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.9
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.10 as Kirigami
import org.kde.plasma.core 2.1 as PlasmaCore
import org.kde.plasma.private.volume 0.1

Kirigami.ApplicationWindow {
    title: "Audio Device Chooser"
    reachableModeEnabled: false
    visibility: "Maximized"
    width: 640
    height: 800

    pageStack.initialPage: mainPage

    Kirigami.Page {
        id: mainPage

        title: "Audio Device Chooser"

        SourceModel {
            id: paSourceModel
        }

        SinkModel {
                id: paSinkModel
        }

        RowLayout {
            id: contentLayout
            anchors.fill: parent
            anchors.margins: Kirigami.Units.largeSpacing


            Rectangle {
                id: mainRectLeft
                Layout.preferredWidth: Kirigami.Units.gridUnit * 10
                Layout.fillHeight: true
                color: Qt.darker(Kirigami.Theme.backgroundColor, 1.2)

                ColumnLayout{
                    id: playbackItemLayout
                    anchors.fill: parent

                    Kirigami.Heading {
                        id: pbackDeviceHeading
                        enabled: sinkView.count > 0
                        Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                        text: qsTr("Playback Devices")
                        level: 3
                    }

                    Kirigami.Separator {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                    }

                    Kirigami.Heading {
                        id: recDeviceHeading
                        enabled: sourceView.count > 0
                        Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                        text: qsTr("Recording Devices")
                        level: 3
                    }
                }
            }

            Kirigami.Separator {
                Layout.fillHeight: true
                Layout.preferredWidth: 1
            }


            Rectangle {
                id: mainRectRight
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: Qt.darker(Kirigami.Theme.backgroundColor, 1.2)

                ColumnLayout {
                    id: recordItemLayout
                    anchors.fill: parent

                    Rectangle {
                        color: Kirigami.Theme.linkColor
                        Layout.preferredHeight: Kirigami.Units.gridUnit * 2
                        Layout.fillWidth: true
                        RowLayout {
                            id: pbLabelsBar
                            anchors.fill: parent
                            Kirigami.Heading {
                                Layout.alignment: Qt.AlignLeft
                                Layout.leftMargin: Kirigami.Units.largeSpacing
                                text: "Output Devices"
                                level: 3
                            }
                            Kirigami.Separator {
                                Layout.fillHeight: true
                                Layout.preferredWidth: 1
                            }
                            Kirigami.Heading {
                                Layout.alignment: Qt.AlignLeft
                                Layout.leftMargin: Kirigami.Units.largeSpacing
                                text: "Default"
                                level: 3
                            }
                        }
                    }

                    Item {
                        Layout.fillHeight: true
                        Layout.fillWidth: true

                        ListView {
                            id: sinkView
                            model: paSinkModel
                            anchors.fill: parent
                            interactive: true
                            clip: true
                            keyNavigationEnabled: true
                            highlightFollowsCurrentItem: true
                            snapMode: ListView.SnapToItem
                            focus: true
                            delegate: DeviceListItem {
                                isPlayback: true
                                type: "sink"
                                height: Kirigami.Units.gridUnit * 2.5
                            }
                            onModelChanged: console.log(model)
                            KeyNavigation.down: sourceView
                            Keys.onReturnPressed: {
                                currentItem.setDefault()
                            }
                        }
                    }

                    Kirigami.Separator {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                    }

                    Rectangle {
                        color: Kirigami.Theme.linkColor
                        Layout.preferredHeight: Kirigami.Units.gridUnit * 2
                        Layout.fillWidth: true
                        RowLayout {
                            id: rbLabelsBar
                            anchors.fill: parent
                            Kirigami.Heading {
                                Layout.alignment: Qt.AlignLeft
                                Layout.leftMargin: Kirigami.Units.largeSpacing
                                text: "Input Devices"
                                level: 3
                            }
                            Kirigami.Separator {
                                Layout.fillHeight: true
                                Layout.preferredWidth: 1
                            }
                            Kirigami.Heading {
                                Layout.alignment: Qt.AlignLeft
                                Layout.leftMargin: Kirigami.Units.largeSpacing
                                text: "Default"
                                level: 3
                            }
                        }
                    }

                    Item {
                        Layout.fillHeight: true
                        Layout.fillWidth: true

                        ListView {
                            id: sourceView
                            clip: true
                            model: paSourceModel
                            anchors.fill: parent
                            interactive: true
                            keyNavigationEnabled: true
                            highlightFollowsCurrentItem: true
                            snapMode: ListView.SnapToItem
                            delegate: DeviceListItem {
                                isPlayback: false
                                type: "source"
                                height: Kirigami.Units.gridUnit * 2.5
                                Component.onCompleted: console.log(sourceView.count)
                            }
                            KeyNavigation.up: sinkView
                            Keys.onReturnPressed: {
                                currentItem.setDefault()
                            }
                        }
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        sinkView.forceActiveFocus()
    }
}

