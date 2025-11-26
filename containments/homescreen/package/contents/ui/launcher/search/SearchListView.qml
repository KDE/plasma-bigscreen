// SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import QtQuick.Window
import QtQuick.Controls as QQC2

import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.private.nanoshell as NanoShell
import org.kde.bigscreen as Bigscreen

import org.kde.milou as Milou
import org.kde.kirigami 2.19 as Kirigami

Milou.ResultsView {
    id: root

    property var queryTextField
    signal hideOverlayRequested()

    queryString: queryTextField.text
    clip: true
    highlight: activeFocus ? highlightComponent : null

    keyNavigationEnabled: true

    Keys.onUpPressed: {
        currentIndex--;
        Bigscreen.NavigationSoundEffects.playMovingSound();
    }
    Keys.onDownPressed: {
        currentIndex++;
        Bigscreen.NavigationSoundEffects.playMovingSound();
    }

    Component {
        id: highlightComponent

        Rectangle {
            color: Qt.rgba(Kirigami.Theme.highlightColor.r, Kirigami.Theme.highlightColor.g, Kirigami.Theme.highlightColor.b, 0.2)
            radius: Kirigami.Units.cornerRadius
            border.width: 2
            border.color: Kirigami.Theme.highlightColor
        }
    }

    onActivated: {
        root.hideOverlayRequested();
    }
    onUpdateQueryString: {
        queryTextField.text = text
        queryTextField.cursorPosition = cursorPosition
    }

    // Section header
    section.delegate: QQC2.Control {
        id: sectionHeader
        required property string section

        topPadding: Kirigami.Units.gridUnit
        bottomPadding: Kirigami.Units.largeSpacing
        leftPadding: 0
        rightPadding: 0

        contentItem: Kirigami.Heading {
            opacity: 0.7
            text: sectionHeader.section
            elide: Text.ElideRight

            font.weight: Font.Medium
            Accessible.ignored: true
        }
    }


    delegate: MouseArea {
        id: delegate
        height: rowLayout.height
        width: listView.width

        // Go to search bar if this we press up with the first item selected
        KeyNavigation.up: model.index === 0 ? queryTextField : null

        // Used by ResultsView to determine next tab action
        function activateNextAction() {
            queryTextField.forceActiveFocus();
            queryTextField.selectAll();
            listView.currentIndex = -1;
        }

        onClicked: {
            listView.currentIndex = model.index;
            listView.runCurrentIndex();

            root.hideOverlayRequested();
        }
        hoverEnabled: true

        Rectangle {
            anchors.fill: parent
            radius: Kirigami.Units.cornerRadius
            color: delegate.pressed ? Qt.rgba(255, 255, 255, 0.3) : (delegate.containsMouse ? Qt.rgba(255, 255, 255, 0.1) : "transparent")
        }

        RowLayout {
            id: rowLayout
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                leftMargin: Kirigami.Units.gridUnit
                rightMargin: Kirigami.Units.gridUnit
            }

            Kirigami.Icon {
                Layout.alignment: Qt.AlignVCenter
                source: model.decoration
                implicitWidth: Kirigami.Units.iconSizes.large
                implicitHeight: Kirigami.Units.iconSizes.large
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                Layout.topMargin: Kirigami.Units.gridUnit
                Layout.bottomMargin: Kirigami.Units.gridUnit
                spacing: Kirigami.Units.smallSpacing

                Kirigami.Heading {
                    id: title
                    Layout.fillWidth: true
                    Layout.leftMargin: Kirigami.Units.gridUnit
                    Layout.rightMargin: Kirigami.Units.gridUnit

                    maximumLineCount: 1
                    elide: Text.ElideRight
                    text: typeof modelData !== "undefined" ? modelData : model.display

                    font.weight: Font.Medium
                }
                PlasmaComponents.Label {
                    id: subtitle
                    Layout.fillWidth: true
                    Layout.leftMargin: Kirigami.Units.gridUnit
                    Layout.rightMargin: Kirigami.Units.gridUnit

                    maximumLineCount: 1
                    elide: Text.ElideRight
                    text: model.subtext || ""
                    opacity: 0.8
                }
            }
        }
    }
}
