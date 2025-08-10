/*
    SPDX-FileCopyrightText: 2024 Aditya Mehra <aix.m@outlook.com>
    SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2

import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami
import org.kde.bigscreen as Bigscreen

Bigscreen.Dialog {
    id: root

    property real displayScale

    title: i18n("Scale")
    standardButtons: Bigscreen.Dialog.Ok | Bigscreen.Dialog.Cancel
    openFocusItem: contentItem

    onOpened: scaleSlider.value = displayScale

    contentItem: Bigscreen.ButtonDelegate {
        Keys.onRightPressed: {
            scaleSlider.increase();
        }

        Keys.onLeftPressed: {
            scaleSlider.decrease()
        }
        KeyNavigation.down: root.footer

        contentItem: RowLayout {
            spacing: Kirigami.Units.smallSpacing

            QQC2.Slider {
                Layout.fillWidth: true
                id: scaleSlider
                from: 1.0
                to: 3.0
                stepSize: 0.05
                value: displayScale
                snapMode: QQC2.Slider.SnapAlways

                onValueChanged: displayScale = value;
            }

            QQC2.Label {
                id: sliderPercentageValue
                text: Math.round(displayScale * 100) + "%"
                font.pixelSize: Bigscreen.Units.defaultFontPixelSize
            }
        }
    }
}
