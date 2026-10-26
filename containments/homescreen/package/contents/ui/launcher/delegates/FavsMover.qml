/*
    SPDX-FileCopyrightText: 2026 Wolf Luyten <wolfluyten@mailfence.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.bigscreen as Bigscreen
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid
import org.kde.private.biglauncher

Item {
    id: root

    property var modelData

    // Whether the application has an open window
    property bool running: false

    readonly property Item tile: delegate

    readonly property bool moving: local.moverMode

    signal optionsRequested()

    readonly property Flickable listView: {
        var candidate = parent;
        while (candidate){
            if (candidate instanceof Flickable){
                return candidate;
            }
            candidate = candidate.parent;
        }
        return null;
    }

    implicitWidth: listView ? listView.cellWidth : 0
    implicitHeight: listView ? listView.cellHeight : 0

    z: local.moverMode ? 3 : 0

    onActiveFocusChanged: {
        if (activeFocus && !local.moverMode){
            delegate.forceActiveFocus();
        } else if (!activeFocus && local.moverMode) {
            local.moverMode = false;
            local.allowClose = false;
        }
    }

    QtObject {
        id: local
        property bool allowClose: false
        property bool moverMode: false
        property int originalIndex: -1
    }

    function startMoving() {
        local.moverMode = true;
        local.allowClose = false;
        local.originalIndex = listView.currentIndex;
        root.forceActiveFocus();
        listView.contentXAnimation();
    }

    function finishMoving() {
        local.moverMode = false;
        local.allowClose = false;
        delegate.forceActiveFocus();
    }

    // Puts the favorite back where it was
    function cancelMoving() {
        const current = listView.currentIndex;
        if (local.originalIndex >= 0 && current !== local.originalIndex) {
            FavsManager.moveFav(Plasmoid.favsListModel.itemMap(current), local.originalIndex);
            listView.currentIndex = local.originalIndex;
        }
        finishMoving();
    }

    Bigscreen.BackHandler.enabled: local.moverMode
    Bigscreen.BackHandler.onActivated: {
        Bigscreen.NavigationRumble.playCancelRumble();
        root.cancelMoving();
    }

    function closeMover(event){
        if (local.moverMode && local.allowClose){
            Bigscreen.NavigationRumble.playConfirmRumble();
            finishMoving();
            event.accepted = true
        } else{
            event.accepted = false
        }
    }
    Keys.onReturnPressed: (event) => closeMover(event)
    Keys.onLeftPressed: (event) => {
        if (!local.moverMode){
            event.accepted = false;
            return;
        }

        if (listView.currentIndex > 0){
            Bigscreen.NavigationSoundEffects.playMovingSound();
            Bigscreen.NavigationRumble.playNavigationRumble();
            FavsManager.moveFav(Plasmoid.favsListModel.itemMap(listView.currentIndex), listView.currentIndex - 1);
        }
    }
    Keys.onRightPressed: (event) => {
        if (!local.moverMode){
            event.accepted = false;
            return;
        }

        if (listView.currentIndex < listView.count - 1){
            Bigscreen.NavigationSoundEffects.playMovingSound();
            Bigscreen.NavigationRumble.playNavigationRumble();
            FavsManager.moveFav(Plasmoid.favsListModel.itemMap(listView.currentIndex), listView.currentIndex + 1);
        }
    }

    Keys.onPressed: (event) => {
        if (local.moverMode) event.accepted = true
        else event.accepted = false
    }
    Keys.onReleased: (event) => {
        if (local.moverMode){
            event.accepted = true
            if (event.key == Qt.Key_Return && !event.isAutoRepeat){
                local.allowClose = true
            }
        }
        else event.accepted = false
    }

    FavDelegate {
        id: delegate
        anchors.fill: parent
        onLongClick: root.startMoving()
        forceCurrent: local.moverMode
        lifted: local.moverMode
        running: root.running
    }

    component MoveArrow: Kirigami.Icon {
        z: 3
        width: Kirigami.Units.iconSizes.large
        height: width
        y: Math.round(delegate.cardHeight / 2 - height / 2 - Kirigami.Units.gridUnit)
        color: Kirigami.Theme.highlightColor
        isMask: true
        Kirigami.Theme.inherit: false
        Kirigami.Theme.colorSet: Kirigami.Theme.Complementary
    }

    MoveArrow {
        visible: local.moverMode && listView.currentIndex > 0
        source: "go-previous-symbolic"
        x: Math.round((root.width - delegate.cardWidth * 1.1) / 2) - width - Kirigami.Units.smallSpacing
    }

    MoveArrow {
        visible: local.moverMode && listView.currentIndex < listView.count - 1
        source: "go-next-symbolic"
        x: Math.round((root.width + delegate.cardWidth * 1.1) / 2) + Kirigami.Units.smallSpacing
    }
}
