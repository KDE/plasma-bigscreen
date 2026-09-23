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

RowLayout {
    id: root

    property var modelData
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

    implicitWidth: listView ? listView.cellWidth : null
    implicitHeight: listView ? listView.height : null
    onActiveFocusChanged: {
        if (activeFocus && !local.moverMode){
            delegate.forceActiveFocus();
        }
    }

    QtObject {
        id: local
        property bool allowClose: false
        property bool moverMode: false
    }

    function closeMover(event){
        if (local.moverMode && local.allowClose){
            local.moverMode = false
            local.allowClose = false
            delegate.forceActiveFocus()
            event.accepted = true
        } else{
            event.accepted = false
        }
    }
    Keys.onReturnPressed: closeMover(event)
    Keys.onLeftPressed: function(event){
        if (!local.moverMode){
            event.accepted = false;
            return;
        }

        if (listView.currentIndex > 0){
            Bigscreen.NavigationSoundEffects.playMovingSound();
            Bigscreen.NavigationRumble.playNavigationRumble();
            listView.decrementCurrentIndex();
            FavsManager.moveFav(Plasmoid.favsListModel.itemMap(listView.currentIndex+1), listView.currentIndex, false);
        }
    }
    Keys.onRightPressed: function(event){
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

    // prevent navigation when editing the favs order
    Keys.onPressed: function(event){
        if (local.moverMode) event.accepted = true
        else event.accepted = false
    }
    Keys.onReleased: function(event){
        if (local.moverMode){
            event.accepted = true
            if (event.key == Qt.Key_Return && !event.isAutoRepeat){
                local.allowClose = true
            }
        }
        else event.accepted = false
    }

    Kirigami.Icon {
        id: "iconMoveLeft"
        visible: local.moverMode && listView.currentIndex != 0
        source: "arrow-left"

        Kirigami.Theme.inherit: false
        Kirigami.Theme.colorSet: Kirigami.Theme.Complementary

        Layout.preferredWidth: listView.cellWidth * 0.3
        Layout.preferredHeight: width
        Layout.alignment: Qt.AlignVCenter
    }

    FavDelegate{
        id: delegate
        onLongClick: {
            local.moverMode = true
            local.allowClose = false
            root.forceActiveFocus()
            listView.contentXAnimation()
        }
        forceCurrent: local.moverMode
    }

    Kirigami.Icon {
        id: "iconMoveRight"
        visible: local.moverMode && listView.currentIndex != listView.count - 1
        source: "arrow-right"

        Kirigami.Theme.inherit: false
        Kirigami.Theme.colorSet: Kirigami.Theme.Complementary

        Layout.preferredWidth: listView.cellWidth * 0.3
        Layout.preferredHeight: width
        Layout.alignment: Qt.AlignVCenter
    }
}
