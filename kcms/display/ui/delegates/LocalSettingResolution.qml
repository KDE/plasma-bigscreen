/*
    SPDX-FileCopyrightText: 2024 Aditya Mehra <aix.m@outlook.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami
import org.kde.bigscreen as BigScreen
import Qt5Compat.GraphicalEffects

Control {
    id: delegate
    property var currentModeId
    property var modes

    onFocusChanged: {
        if(focus){
            resolutionSelector.forceActiveFocus()
        }
    }

    Behavior on implicitWidth {
        NumberAnimation {
            duration: Kirigami.Units.longDuration
            easing.type: Easing.InOutQuad
        }
    }

    function findIndex(array, value){
        for(var i = 0; i < array.length; i++){
            if(array[i].id === value){
                return i
            }
        }
        return -1
    }

    contentItem: ColumnLayout {

        Rectangle {
            id: textNameBox
            Layout.fillWidth: true
            Layout.preferredHeight: Kirigami.Units.gridUnit * 4
            Kirigami.Theme.inherit: false
            Kirigami.Theme.colorSet: Kirigami.Theme.Window
            color: Kirigami.Theme.alternateBackgroundColor
            border.color: Kirigami.Theme.disabledTextColor
            border.width: 1
            radius: 6

            PlasmaComponents.Label {
                anchors.fill: parent
                anchors.margins: Kirigami.Units.largeSpacing
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                color: Kirigami.Theme.textColor
                fontSizeMode: Text.Fit
                minimumPixelSize: 14
                font.pixelSize: 24
                text: i18n("Available Resolutions")
            }
        }

        ListView {
            id: resolutionSelector
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: modes
            currentIndex: findIndex(modes, currentModeId)
            spacing: Kirigami.Units.smallSpacing
            clip: true
            keyNavigationEnabled: true
            highlightFollowsCurrentItem: true
            snapMode: ListView.SnapOneItem
            KeyNavigation.left: settingMenuItem
            KeyNavigation.down: scaleDelegate
            KeyNavigation.up: nextDisplayButton.enabled ? nextDisplayButton : scaleDelegate

            Component.onCompleted: {
                resolutionSelector.positionViewAtIndex(currentIndex, ListView.Center)
            }

            delegate: ItemDelegate {
                id: resolutionItem
                width: resolutionSelector.width
                height: Kirigami.Units.gridUnit * 3

                background: Kirigami.ShadowedRectangle {
                    color: delegate.currentModeId == modelData.id ? Kirigami.Theme.disabledTextColor : Kirigami.Theme.backgroundColor
                    border.width: 4
                    border.color: resolutionSelector.currentIndex == index && resolutionItem.activeFocus ? Kirigami.Theme.highlightColor : Kirigami.Theme.backgroundColor
                    radius: 6

                    shadow {
                        size: Kirigami.Units.largeSpacing
                    }
                }

                contentItem: Item {
                    PlasmaComponents.Label {
                        id: availableResolutionText
                        anchors.fill: parent
                        anchors.margins: Kirigami.Units.largeSpacing
                        text: modelData.displayText
                        color: Kirigami.Theme.textColor
                        fontSizeMode: Text.Fit
                        minimumPixelSize: 14
                        font.pixelSize: 24
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                onClicked: {
                    confirmationDialog.selectedOutput = displayRepeater.currentItem.displayOutputName
                    confirmationDialog.selectedResolution = modelData.displayText
                    confirmationDialog.selectedModeId = modelData.id
                    confirmationDialog.open()
                }

                Keys.onReturnPressed: {
                    clicked()
                }
            }
        }
    }
}
