/*
    SPDX-FileCopyrightText: 2026 Wolf Luyten <wolfluyten@mailfence.com>
    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Layouts

import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami

import "delegates" as Delegates
import org.kde.bigscreen as Bigscreen

FocusScope {
    id: root

    onFocusChanged: {
        if (focus) view.forceActiveFocus();
    }

    // should use the same values (rounded down) as LauncherHome
    property real columns: {
        if (view.Window && view.Window.window) {
            var v = 5;
            switch (true) {
                case (view.Window.window.width <= 1280 && view.Window.window.width > 1024):
                    v = 4;
                    break;
                case (view.Window.window.width <= 1024 && view.Window.window.width > 800):
                    v = 3;
                    break;
                case (view.Window.window.width <= 800):
                    v = 2;
                    break;
            }
            return v;
        } else {
            return 1; // or any default value you prefer ( != 0 )
        }
    }

    GridView {
        id: view

        anchors.fill: parent
        anchors.topMargin: Kirigami.Units.gridUnit * 2

        keyNavigationEnabled: true
        keyNavigationWraps: false

        model: Plasmoid.applicationListModel

        reuseItems: true
        cacheBuffer: cellHeight * 4
        displayMarginBeginning: cellHeight * 2
        focus: true
        flow: GridView.FlowLeftToRight
        snapMode: GridView.SnapOneRow

        cellWidth: root.width / root.columns
        cellHeight: cellWidth * 0.75
        delegate: Delegates.AppDelegate {
            property var modelData: typeof model !== "undefined" ? model : null
        }

        onCurrentIndexChanged: {
            Bigscreen.NavigationSoundEffects.playMovingSound();
            Bigscreen.NavigationRumble.playNavigationRumble();
            const maxContentY = Math.max(0, contentHeight - height + cellHeight);
            yAnim.to = Math.max(0, Math.min(currentItem.y, maxContentY));
            yAnim.restart();
        }

        NumberAnimation on contentY {
            id: yAnim
            easing.type: Easing.OutCubic
            duration: Kirigami.Units.longDuration
        }

        // Prevent going to the next/previous line of the grid
        Keys.onLeftPressed: function(event){
            if (currentIndex % root.columns == 0) event.accepted = true;
            else event.accepted = false;
        }
        Keys.onRightPressed: function(event){
            if (currentIndex % root.columns == root.columns - 1) event.accepted = true;
            else event.accepted = false;
        }

        // If there's no item underneath, but there is a next row
        Keys.onDownPressed: function(event){
            if (count - currentIndex - 1 < root.columns && currentIndex < count - (count % root.columns == 0 ? root.columns : count % root.columns)){
                currentIndex = count - 1;
                event.accepted = true;
            } else{
                event.accepted = false;
            }
        }
    }
}
