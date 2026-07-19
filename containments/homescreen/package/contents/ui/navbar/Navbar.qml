// SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
// SPDX-FileCopyrightText: 2019 Aditya Mehra <aix.m@outlook.com>
// SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import "../indicators" as Indicators
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import QtQuick.Window
import org.kde.bigscreen as Bigscreen
import org.kde.coreaddons as KCoreAddons
import org.kde.kirigami as Kirigami
import org.kde.kirigamiaddons.components as KirigamiComponents
import org.kde.kquickcontrolsaddons
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid

Controls.Control {
    id: root

    property alias activeTabIndex: navPill.activeTabIndex
    
    readonly property real largeHeight: Math.min(parent.height / 2, Kirigami.Units.gridUnit * 15)
    readonly property real shrunkHeight: Kirigami.Units.gridUnit * 7

    state: "large"
    // Forward focus to first item
    onActiveFocusChanged: {
        if (activeFocus)
            searchIndicator.forceActiveFocus();

    }
    topPadding: 0
    bottomPadding: 0
    leftPadding: 0
    rightPadding: 0
    states: [
        State {
            name: "large"

            PropertyChanges {
                target: clock
                state: "column"
            }

            PropertyChanges {
                target: root
                height: root.largeHeight
            }

            PropertyChanges {
                target: root
                topPadding: Math.min(largeHeight - clock.clockBigHeight - Kirigami.Units.gridUnit * 2, Kirigami.Units.gridUnit * 6)
            }

        },
        State {
            name: "shrunk" // When the user scrolls down in the homescreen

            PropertyChanges {
                target: clock
                state: "row"
            }

            PropertyChanges {
                target: root
                height: root.shrunkHeight
            }

            PropertyChanges {
                target: root
                topPadding: Kirigami.Units.gridUnit * 1
            }

        }
    ]

    transitions: Transition {
        PropertyAnimation {
            target: root
            property: 'height'
            duration: 200
            easing.type: Easing.InOutCubic
        }

        PropertyAnimation {
            target: root
            property: 'topPadding'
            duration: 200
            easing.type: Easing.InOutCubic
        }

    }

    contentItem: RowLayout {
        id: rowLayout

        spacing: Kirigami.Units.largeSpacing
        Kirigami.Theme.inherit: false
        Kirigami.Theme.colorSet: Kirigami.Theme.Complementary

        Indicators.Clock {
            id: clock

            Layout.alignment: Qt.AlignTop | Qt.AlignLeft
        }

        // spacer
        Item {
            Layout.fillWidth: true
        }

        // Center Navigation Pill
        Rectangle {
            id: navPill
            
            property int activeTabIndex: 1

            Layout.alignment: Qt.AlignTop | Qt.AlignHCenter
            Layout.preferredHeight: Kirigami.Units.gridUnit * 2.5
            
            Layout.preferredWidth: innerLayout.implicitWidth + (Kirigami.Units.largeSpacing * 2) 
            color: Qt.rgba(1, 1, 1, 0.2)
            radius: height / 2

            RowLayout {
                id: innerLayout

                anchors.centerIn: parent
                spacing: Kirigami.Units.largeSpacing * 2

                Controls.Label {
                    text: "(L1)"
                    font.weight: Font.Bold
                    color: "white"
                    opacity: 0.6
                }

                Repeater {
                    model: ["HOME", "GAMES", "STORE"]

                    delegate: Rectangle {
                        property bool isSelected: index === navPill.activeTabIndex

                        // FIX 4: Use implicitWidth/Height for items inside a RowLayout
                        implicitWidth: tabText.implicitWidth + (Kirigami.Units.largeSpacing * 3)
                        implicitHeight: navPill.height - (Kirigami.Units.smallSpacing * 2)
                        radius: height / 2
                        
                        color: isSelected ? "white" : "transparent"

                        Controls.Label {
                            id: tabText
                            anchors.centerIn: parent
                            text: modelData
                            font.weight: Font.Bold
                            color: isSelected ? "black" : "white"
                            opacity: isSelected ? 1 : 0.8
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: navPill.activeTabIndex = index
                        }

                        Behavior on color {
                            ColorAnimation {
                                duration: 150
                            }
                        }
                    }
                }

                Controls.Label {
                    text: "(R1)"
                    font.weight: Font.Bold
                    color: "white"
                    opacity: 0.6
                }
            }
        }

        // spacer
        Item {
            Layout.fillWidth: true
        }

        RowLayout {
            Layout.alignment: Qt.AlignTop | Qt.AlignRight
            spacing: Kirigami.Units.gridUnit

            Indicators.Search {
                id: searchIndicator

                KeyNavigation.right: favsIndicator
                KeyNavigation.tab: favsIndicator
            }

            Indicators.Favorites {
                id: favsIndicator

                KeyNavigation.left: searchIndicator
                KeyNavigation.backtab: searchIndicator
                KeyNavigation.right: settingsIndicator
                KeyNavigation.tab: settingsIndicator
            }

        }

    }

}
