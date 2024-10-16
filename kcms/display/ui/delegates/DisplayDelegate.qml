/*
    SPDX-FileCopyrightText: 2024 Aditya Mehra <aix.m@outlook.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.kirigami as Kirigami

Item {
    id: displayDelegateItem
    property var displayOutputName: model.outputName
    property var displaySizeString: model.size.width + "x" + model.size.height
    property var displayCurrentModeId: model.currentModeId
    property var displayCurrentRefreshRate: kcm.displayModel.getCurrentRefreshRate(model.currentModeId)

    onFocusChanged: {
        if(focus){
            resolutionDelegate.forceActiveFocus()
        }
    }

    Item {
        id: displayContentLayout
        anchors.fill: parent
        anchors.margins: Kirigami.Units.largeSpacing

        LocalSettingResolution {
            id: resolutionDelegate
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: scaleDelegate.top
            currentModeId: model.currentModeId
            modes: model.modes
        }

        LocalSettingScale {
            id: scaleDelegate
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: Kirigami.Units.gridUnit * 4
            currentModeId: model.currentModeId
            displayScale: model.scale
        }
    }
}