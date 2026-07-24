/*
 * SPDX-FileCopyrightText: 2022 Aditya Mehra <aix.m@outlook.com>
 * SPDX-FileCopyrightText: 2020 Marco Martin <mart@kde.org>
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick
import QtQuick.Layouts
import QtQuick.Window
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami
import org.kde.bigscreen as Bigscreen

FocusScope {
    id: root
    signal activated

    property alias view: view
    property alias delegate: view.delegate
    property alias model: view.model
    property alias currentIndex: view.currentIndex
    property alias currentItem: view.currentItem
    property alias count: view.count
    property bool titleVisible: true

    Layout.fillWidth: true
    implicitHeight: view.implicitHeight

    // Responsive grid logic
    property real columns: {
        const windowWidth = root.Window.width || 0;
            if (windowWidth > 1280) return 6;
            if (windowWidth > 1024) return 5;
            return 4;
    }


    property alias cellWidth: view.cellWidth
    property alias cellHeight: view.cellHeight
    
    property Item navigationUp
    property Item navigationDown

    onActiveFocusChanged: {
        if (activeFocus && currentItem) {
            currentItem.forceActiveFocus();
        }
    }

    ListView {
        id: view
        anchors.fill:parent

        // Layout settings
        orientation: ListView.Horizontal
        spacing: Kirigami.Units.largeSpacing * 4
        snapMode: ListView.SnapOneItem
        highlightRangeMode: ListView.StrictlyEnforceRange
        
        // Native Performance Settings
        keyNavigationEnabled: true
        reuseItems: true
        focus: true
        cacheBuffer: width * 2
        highlightMoveDuration: Kirigami.Units.longDuration

        // Math: Total width minus total spacing divided by columns
        readonly property int cellWidth: (root.width - ((columns - 1) * spacing)) / columns
        readonly property int cellHeight: cellWidth * 1.50

        implicitHeight: cellHeight

        // Snap Logic: Setting preferredHighlight to cellWidth + spacing
        // tells the ListView exactly where to center the item.
        preferredHighlightBegin: 0
        preferredHighlightEnd: 0 //cellWidth + spacing

        Keys.onLeftPressed: (event) => {
            if (currentIndex > 0) {
                Bigscreen.NavigationSoundEffects.playMovingSound();
                currentIndex--;
                event.accepted = true;
            }
        }

        Keys.onRightPressed: (event) => {
            if (currentIndex < count - 1) {
                Bigscreen.NavigationSoundEffects.playMovingSound();
                currentIndex++;
                event.accepted = true;
            }
        }

        onCurrentItemChanged: {
            if (root.activeFocus && currentItem) {
                currentItem.forceActiveFocus();
            }
        }

        Keys.onDownPressed: {
            if (!root.navigationDown) return;
            Bigscreen.NavigationSoundEffects.playMovingSound();
            root.navigationDown.forceActiveFocus();
        }

        Keys.onUpPressed: {
            if (!root.navigationUp) return;
            
            Bigscreen.NavigationSoundEffects.playMovingSound();
            root.navigationUp.forceActiveFocus();
        }
    }
}