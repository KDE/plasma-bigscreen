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
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.private.volume 0.1
import QtQuick.Window 2.2

import "delegates" as Delegates
import "views" as Views

Window {
    title: "Audio Device Chooser"
    visibility: "Maximized"
    color: Qt.rgba(0, 0, 0, 0.4)
    property Component highlighter: PlasmaComponents.Highlight{}
    property Component emptyHighlighter: Item{}

    Item {
        id: mainPage
        anchors.fill: parent

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

            Item {
                id: mainRectLeft
                Layout.preferredWidth: Kirigami.Units.gridUnit * 10
                Layout.fillHeight: true

                ColumnLayout{
                    id: playbackItemLayout
                    anchors.fill: parent

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: sinkView.activeFocus ? Kirigami.Theme.linkColor : Qt.darker(Kirigami.Theme.backgroundColor, 1.2)
                        Kirigami.Heading {
                            id: pbackDeviceHeading
                            enabled: sinkView.count > 0
                            anchors.centerIn: parent
                            text: qsTr("Playback Devices")
                            level: 3
                        }
                    }
                    Kirigami.Separator {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                    }
                    Rectangle{
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: sourceView.activeFocus ? Kirigami.Theme.linkColor : Qt.darker(Kirigami.Theme.backgroundColor, 1.2)
                        Kirigami.Heading {
                            id: recDeviceHeading
                            enabled: sourceView.count > 0
                            //Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                            anchors.centerIn: parent
                            text: qsTr("Recording Devices")
                            level: 3
                        }
                    }
                }
            }

            Kirigami.Separator {
                Layout.fillHeight: true
                Layout.preferredWidth: 1
                Layout.rightMargin: Kirigami.Units.largeSpacing
            }

            Item {
                id: mainRectRight
                Layout.fillWidth: true
                Layout.fillHeight: true

                ColumnLayout {
                    id: recordItemLayout
                    anchors.fill: parent

                    Views.TileView {
                        id: sinkView
                        model: paSinkModel
                        clip: true
                        focus: true
                        highlight: focus ? highlighter : emptyHighlighter
                        highlightMoveDuration: 0
                        delegate: Delegates.AudioDelegate {
                            isPlayback: true
                            anchors.verticalCenter: parent.verticalCenter
                            type: "sink"
                        }
                        KeyNavigation.down: sourceView
                        Keys.onReturnPressed: {
                            currentItem.setDefault()
                        }
                    }

                    Kirigami.Separator {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                    }

                    Views.TileView {
                        id: sourceView
                        clip: true
                        model: paSourceModel
                        highlight: focus ? highlighter : emptyHighlighter
                        highlightMoveDuration: 0
                        delegate: Delegates.AudioDelegate {
                            isPlayback: false
                            anchors.verticalCenter: parent.verticalCenter
                            type: "source"
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

    Component.onCompleted: {
        sinkView.forceActiveFocus()
    }
}

