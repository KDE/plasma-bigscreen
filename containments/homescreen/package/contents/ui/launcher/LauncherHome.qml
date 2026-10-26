/*
    SPDX-FileCopyrightText: 2019 Aditya Mehra <aix.m@outlook.com>
    SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import QtQuick.Window

import org.kde.plasma.plasmoid
import org.kde.kquickcontrolsaddons
import org.kde.kirigami as Kirigami
import org.kde.kitemmodels as KItemModels

import "delegates" as Delegates
import org.kde.bigscreen as Bigscreen
import org.kde.private.biglauncher 1.0
import org.kde.plasma.private.kicker 0.1 as Kicker
import org.kde.taskmanager as TaskManager

FocusScope {
    id: root

    property Item navigationUp

    property real bottomMargin

    // Space at the top covered by the header, which the hero must stay below
    property real topReservedHeight

    // Emitted when an app's card is held
    signal optionsRequested(var app, Item mover)

    // The favorite being moved
    readonly property Item movingFavorite: (favAppsView.currentItem && favAppsView.currentItem.moving) ? favAppsView.currentItem : null

    // Whether the view has scrolled down at least one row
    readonly property bool scrolledDown: launcherHomeColumn.currentSection && launcherHomeColumn.currentSection !== favAppsView.currentViewDownwards

    readonly property int amountOfVisibleRows: {
        let amountVisible = 0;
        for (var i = 0; i < listsContainer.children.length; i++) {
            if (listsContainer.children[i].visible) amountVisible++;
        }
        return amountVisible;
    }

    function requestOptions(storageId: string, name: string, iconName: string, description: string, mover: Item) {
        if (!storageId) {
            return;
        }
        root.optionsRequested({
            storageId: storageId,
            name: name,
            iconName: iconName,
            description: description,
            running: root.isRunning(storageId),
            canMove: mover !== null
        }, mover);
    }

    // Back goes to the first row before it opens the home overlay
    Bigscreen.BackHandler.enabled: root.scrolledDown && root.movingFavorite === null
    Bigscreen.BackHandler.onActivated: {
        Bigscreen.NavigationRumble.playNavigationRumble();
        root.activateAppView();
    }

    function activateAppView() {
        favAppsView.currentViewDownwards?.forceActiveFocus();
    }

    // Rows above the focused row fade out, rows below are dimmed
    function sectionOpacity(section: Item): real {
        const current = launcherHomeColumn.currentSection;
        if (!current || section === current) {
            return 1;
        }
        return section.y < current.y ? 0 : 0.5;
    }

    Component.onCompleted: {
        updateFavoriteStorageIds();
        activateAppView();
    }

    TaskManager.TasksModel {
        id: tasksModel
        filterByVirtualDesktop: false
        filterByActivity: false
        filterNotMaximized: false
        filterByScreen: false
        filterHidden: true
        groupMode: TaskManager.TasksModel.GroupDisabled
    }

    Instantiator {
        id: runningApps
        model: tasksModel
        delegate: QtObject {
            required property var model
            readonly property string appId: model.AppId ?? ""
        }
    }

    readonly property var runningAppIds: {
        const ids = [];
        for (let i = 0; i < runningApps.count; ++i) {
            const obj = runningApps.objectAt(i);
            if (obj && obj.appId.length > 0) {
                ids.push(obj.appId);
            }
        }
        return ids;
    }

    function isRunning(storageId: string): bool {
        if (!storageId) {
            return false;
        }
        const appId = storageId.endsWith(".desktop") ? storageId.slice(0, -8) : storageId;
        return runningAppIds.includes(storageId) || runningAppIds.includes(appId);
    }

    Connections {
        target: Plasmoid.applicationListModel

        function onBlocklistChanged() {
            recentModel.invalidateFilter();
        }
    }

    ColumnLayout {
        id: launcherHomeColumn
        anchors {
            left: parent.left
            right: parent.right
        }
        property Item currentSection
        readonly property Item firstSection: favAppsView.currentViewDownwards

        y: parent.y + parent.height;
        function intendedY() {
            if (!currentSection) {
                return parent.y + parent.height;
            }
            if (amountOfVisibleRows == 1) {
                return parent.y + parent.height - currentSection.height - root.bottomMargin;
            }
            return Math.round(Math.max(
                // note that there isn't a full half of the next row visible because the
                // header isn't accounted for
                -currentSection.y + parent.y + parent.height - currentSection.height * (3/2) - listsContainer.spacing,
                parent.y + parent.height - height - root.bottomMargin
            ));
        }

        onCurrentSectionChanged: {
            // Use manual Animation instead of Behavior to prevent animations every time the screen is resized
            y = y; // Break binding before starting animation to prevent glitches
            yAnim.to = intendedY();
            yAnim.restart();
        }

        NumberAnimation on y {
            id: yAnim
            duration: Kirigami.Units.veryLongDuration
            easing.type: Easing.OutCubic

            // Set binding so that screen resizes affect Y
            onFinished: {
                launcherHomeColumn.y = Qt.binding(() => launcherHomeColumn.intendedY());
            }
        }

        ColumnLayout {
            id: listsContainer
            spacing: Kirigami.Units.largeSpacing * 3

            DelegateListView {
                id: favAppsView
                // Recursively get the next visible view
                property var currentViewUpwards: visible ? favAppsView : root.navigationUp
                property var currentViewDownwards: visible ? favAppsView : recentView.currentViewDownwards

                title: i18n("Favorites")
                titleVisible: root.amountOfVisibleRows == 1 ? false : true
                model: Plasmoid.favsListModel
                currentIndex: 0
                focus: visible
                onActiveFocusChanged: if (activeFocus)
                    launcherHomeColumn.currentSection = favAppsView

                delegate: Delegates.FavsMover {
                    id: favMover
                    modelData: typeof model !== "undefined" ? model : null
                    running: modelData ? root.isRunning(modelData.ApplicationStorageIdRole) : false

                    // Other favorites are dimmed while one is moved
                    opacity: (root.movingFavorite && root.movingFavorite !== favMover) ? 0.5 : 1
                    Behavior on opacity { OpacityAnimator { duration: Kirigami.Units.longDuration } }

                    onOptionsRequested: root.requestOptions(modelData.ApplicationStorageIdRole, modelData.ApplicationNameRole,
                                                            modelData.ApplicationIconRole, modelData.ApplicationCommentRole ?? "", favMover)
                }

                opacity: root.sectionOpacity(favAppsView)
                Behavior on opacity { OpacityAnimator { duration: Kirigami.Units.longDuration } }

                navigationUp: root.navigationUp
                navigationDown: recentView.currentViewDownwards
            }

            DelegateListView {
                id: recentView
                property var currentViewUpwards: visible ? recentView : favAppsView.currentViewUpwards
                property var currentViewDownwards: visible ? recentView : appsView.currentViewDownwards
                readonly property int favoriteIdRole: Qt.UserRole + 3

                function sourceIndex(row) {
                    return recentView.model.mapToSource(recentView.model.index(row, 0));
                }

                title: i18n("Recent")
                titleVisible: root.amountOfVisibleRows == 1 ? false : true

                // columnOffset: 2
                opacity: root.sectionOpacity(recentView)
                Behavior on opacity { OpacityAnimator { duration: Kirigami.Units.longDuration } }

                model: KItemModels.KSortFilterProxyModel {
                    id: recentModel
                    sourceModel: Kicker.RecentUsageModel {
                        shownItems: Kicker.RecentUsageModel.OnlyApps
                    }
                    filterRowCallback: function(sourceRow, sourceParent) {
                        const sourceIndex = sourceModel.index(sourceRow, 0, sourceParent);
                        const storageId = sourceIndex.data(recentView.favoriteIdRole);
                        return !Plasmoid.applicationListModel.isApplicationBlocklisted(storageId);
                    }
                }

                visible: Plasmoid.configuration.showRecent && count > 0
                currentIndex: 0
                focus: visible && (favAppsView.currentViewUpwards === root.navigationUp)
                onActiveFocusChanged: if (activeFocus)
                    launcherHomeColumn.currentSection = recentView

                delegate: Delegates.AppDelegate {
                    property real sectionOpacity: 1.0
                    property var modelData: typeof model !== "undefined" ? model : null
                    applicationStorageId: modelData ? (modelData.favoriteId ?? "") : ""
                    launchApplication: function() {
                        recentView.model.sourceModel.trigger(recentView.sourceIndex(index).row, "", null);
                    }
                    iconImage: model.decoration
                    text: model.display
                    subtitle: model.description ?? ""
                    running: root.isRunning(applicationStorageId)
                    onLongClick: root.requestOptions(applicationStorageId, text, "", subtitle, null)
                }

                navigationUp: favAppsView.currentViewUpwards
                navigationDown: appsView.currentViewDownwards
            }

            DelegateListView {
                id: appsView
                property var currentViewUpwards: visible ? appsView : recentView.currentViewUpwards
                property var currentViewDownwards: visible ? appsView : gamesView.currentViewDownwards

                title: i18n("Applications")
                titleVisible: root.amountOfVisibleRows == 1 ? false : true
                // columnOffset: 2
                opacity: root.sectionOpacity(appsView)
                Behavior on opacity { OpacityAnimator { duration: Kirigami.Units.longDuration } }

                visible: Plasmoid.configuration.showApplications && count > 0
                enabled: count > 0
                model: KItemModels.KSortFilterProxyModel {
                    sourceModel: Plasmoid.applicationListModel
                    filterRoleName: "ApplicationCategoriesRole"
                    filterRowCallback: function (source_row, source_parent) {
                        var cats = sourceModel.data(sourceModel.index(source_row, 0, source_parent), ApplicationListModel.ApplicationCategoriesRole);
                        return cats.indexOf("Game") === -1;
                    }
                }

                currentIndex: 0
                focus: visible && (recentView.currentViewUpwards === root.navigationUp)
                onActiveFocusChanged: if (activeFocus)
                    launcherHomeColumn.currentSection = appsView
                delegate: Delegates.AppDelegate {
                    property var modelData: typeof model !== "undefined" ? model : null
                    running: root.isRunning(applicationStorageId)
                    onLongClick: root.requestOptions(applicationStorageId, text, icon.name, subtitle, null)
                }

                navigationUp: recentView.currentViewUpwards
                navigationDown: gamesView.currentViewDownwards
            }

            DelegateListView {
                id: gamesView
                property var currentViewUpwards: visible ? gamesView : appsView.currentViewUpwards
                property var currentViewDownwards: visible ? gamesView : null

                title: i18n("Games")
                titleVisible: root.amountOfVisibleRows == 1 ? false : true

                columnOffset: -1
                cardAspectRatio: 215 / 460 // Wider cards for games
                opacity: root.sectionOpacity(gamesView)
                Behavior on opacity { OpacityAnimator { duration: Kirigami.Units.longDuration } }

                visible: Plasmoid.configuration.showGames && count > 0
                enabled: count > 0
                model: KItemModels.KSortFilterProxyModel {
                    sourceModel: Plasmoid.applicationListModel
                    filterRoleName: "ApplicationCategoriesRole"
                    filterRowCallback: function (source_row, source_parent) {
                        return sourceModel.data(sourceModel.index(source_row, 0, source_parent), ApplicationListModel.ApplicationCategoriesRole).indexOf("Game") !== -1;
                    }
                }

                currentIndex: 0
                focus: visible && (appsView.currentViewUpwards === root.navigationUp)
                onActiveFocusChanged: if (activeFocus)
                    launcherHomeColumn.currentSection = gamesView
                delegate: Delegates.AppDelegate {
                    property var modelData: typeof model !== "undefined" ? model : null
                    running: root.isRunning(applicationStorageId)
                    onLongClick: root.requestOptions(applicationStorageId, text, icon.name, subtitle, null)
                }

                navigationUp: appsView.currentViewUpwards
                navigationDown: null
            }
        }
    }
}
