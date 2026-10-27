// SPDX-FileCopyrightText: 2026 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2

import org.kde.kirigami as Kirigami
import org.kde.bigscreen as Bigscreen
import org.kde.plasma.plasmoid
import org.kde.private.biglauncher

Bigscreen.SidebarOverlay {
    id: root

    property string storageId
    property string name
    property string iconName
    property string description
    property bool running: false

    // Whether the app can be moved (favorites row)
    property bool canMove: false

    signal moveRequested()

    readonly property bool favorite: favoriteIds.includes(storageId)
    property var favoriteIds: []

    // Input is ignored until the select button that opened the drawer is let go so that holding it doesn't also choose the first action
    property bool armed: false

    property Item restoreFocusItem

    function restoreFocus() {
        if (restoreFocusItem) {
            restoreFocusItem.forceActiveFocus();
            restoreFocusItem = null;
        }
    }

    onClosed: restoreFocus()

    // app: { storageId, name, iconName, description, running, canMove }
    function openFor(app, focusItem) {
        restoreFocusItem = focusItem ?? null;
        storageId = app.storageId ?? "";
        name = app.name ?? "";
        iconName = app.iconName || (Plasmoid.applicationListModel.itemMapForStorageId(storageId).icon ?? "");
        description = app.description ?? "";
        running = app.running ?? false;
        canMove = app.canMove ?? false;

        const ids = [];
        const favs = Plasmoid.favsListModel;
        for (let i = 0; i < favs.count; ++i) {
            ids.push(favs.itemMap(i).storageId);
        }
        favoriteIds = ids;

        armed = false;
        armTimer.restart();
        actionList.currentIndex = 0;
        open();
    }

    function trigger(action: string) {
        if (!armed) {
            return;
        }
        Bigscreen.NavigationSoundEffects.playClickedSound();
        Bigscreen.NavigationRumble.playConfirmRumble();
        close();
        // Give focus back first, since some actions move it again
        restoreFocus();

        switch (action) {
        case "move":
            root.moveRequested();
            break;
        case "addFavorite":
            FavsManager.addFav(Plasmoid.applicationListModel.itemMapForStorageId(root.storageId));
            Plasmoid.showOSD(i18n("Added %1 to Favorites", root.name), "starred-symbolic");
            break;
        case "removeFavorite":
            removeFavorite();
            Plasmoid.showOSD(i18n("Removed %1 from Favorites", root.name), "non-starred-symbolic");
            break;
        case "hide":
            removeFavorite();
            Plasmoid.applicationListModel.setApplicationBlocklisted(root.storageId, true);
            Plasmoid.showOSD(i18n("%1 hidden. Show it again from Edit Home Screen.", root.name), "view-hidden-symbolic");
            break;
        }
    }

    function removeFavorite() {
        const favs = Plasmoid.favsListModel;
        for (let i = 0; i < favs.count; ++i) {
            const fav = favs.itemMap(i);
            if (fav.storageId === root.storageId) {
                FavsManager.removeFav(fav);
                return;
            }
        }
    }

    readonly property var actions: {
        const list = [];
        if (root.canMove) {
            list.push({ action: "move", text: i18n("Move"), icon: "transform-move-horizontal" });
        }
        list.push(root.favorite
            ? { action: "removeFavorite", text: i18n("Remove from Favorites"), description: "", icon: "non-starred-symbolic" }
            : { action: "addFavorite", text: i18n("Add to Favorites"), icon: "starred-symbolic" });
        list.push({ action: "hide", text: i18n("Hide from Homescreen"), icon: "view-hidden-symbolic" });
        return list;
    }

    Timer {
        id: armTimer
        interval: 1000
        onTriggered: root.armed = true
    }

    openFocusItem: actionList

    header: Bigscreen.SidebarOverlayHeader {
        iconSource: root.iconName
        title: root.name
        subtitle: root.running ? i18n("Running") : root.description
    }

    content: ListView {
        id: actionList
        keyNavigationEnabled: true
        spacing: Kirigami.Units.smallSpacing
        clip: true
        model: root.actions

        Keys.onReleased: (event) => {
            if ((event.key === Qt.Key_Return || event.key === Qt.Key_Enter) && !event.isAutoRepeat) {
                root.armed = true;
            }
        }

        delegate: Bigscreen.ButtonDelegate {
            required property var modelData

            width: actionList.width
            text: modelData.text
            icon.name: modelData.icon

            onClicked: root.trigger(modelData.action)
        }
    }
}
