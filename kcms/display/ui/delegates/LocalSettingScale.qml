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
    property var displayScale

    onFocusChanged: {
        if(focus){
            scaleSlider.forceActiveFocus()
        }
    }

    background: Kirigami.ShadowedRectangle {
        color: Kirigami.Theme.alternateBackgroundColor
        radius: 6
        border.width: 4
        border.color: scaleSlider.focus ? Kirigami.Theme.highlightColor : Kirigami.Theme.alternateBackgroundColor

        shadow {
            size: Kirigami.Units.largeSpacing
        }
    }

    contentItem: RowLayout {
        id: localItem
              
        PlasmaComponents.Label {
            id: textName
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            color: Kirigami.Theme.textColor
            fontSizeMode: Text.Fit
            minimumPixelSize: 14
            font.pixelSize: 24
            text: i18n("Scale")
        }

        Slider {
            id: scaleSlider
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            from: 1.0
            to: 3.0
            stepSize: 0.25
            value: displayScale
            snapMode: Slider.SnapAlways
            KeyNavigation.left: settingMenuItem
            KeyNavigation.up: resolutionSelector
            KeyNavigation.down: previousDisplayButton.enabled ? previousDisplayButton : resolutionSelector

            Keys.onRightPressed: {
                scaleSlider.increase()
                value = scaleSlider.value
            }

            Keys.onLeftPressed: {
                scaleSlider.decrease()
                value = scaleSlider.value
            }

            onValueChanged: {
                displayScale = value
                kcm.displayModel.setScaleConfiguration(displayScale, displayRepeater.currentItem.displayOutputName)
                sliderPercentageValue.text = Math.round(displayScale * 100) + "%"
            }
        }

        Rectangle {
            Layout.preferredWidth: Kirigami.Units.gridUnit * 5
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            color: Kirigami.Theme.textColor
            radius: 6

            PlasmaComponents.Label {
                id: sliderPercentageValue
                text: Math.round(displayScale * 100) + "%"
                color: Kirigami.Theme.backgroundColor
                fontSizeMode: Text.Fit
                minimumPixelSize: 8
                font.pixelSize: 18
                anchors.centerIn: parent
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }
    }
}
