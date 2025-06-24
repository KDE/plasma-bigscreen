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
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.kquickcontrolsaddons
import org.kde.kirigami as Kirigami
import org.kde.kitemmodels as KItemModels

import "delegates" as Delegates
import org.kde.bigscreen as Bigscreen
import org.kde.private.biglauncher 1.0
import org.kde.plasma.private.kicker 0.1 as Kicker

FocusScope {
    id: root

    property Item navigationUp

    property real startY

    // Whether the view has scrolled down at least one row
    readonly property bool scrolledDown: launcherHomeColumn.currentSection && launcherHomeColumn.currentSection !== favAppsView.currentViewDownwards

    ColumnLayout {
        id: launcherHomeColumn
        anchors {
            left: parent.left
            right: parent.right
        }
        property Item currentSection
        readonly property Item firstSection: favAppsView.currentViewDownwards

        y: root.startY
        function intendedY() {
            if (!currentSection) {
                return startY;
            } else if (firstSection == currentSection) {
                return startY;
            }
            return Math.round(-currentSection.y + startY - currentSection.height/2);
        }

        onCurrentSectionChanged: {
            // Use manual Animation instead of Behavior to prevent animations every time the screen is resized
            y = y; // Break binding before starting animation to prevent glitches
            yAnim.to = intendedY();
            yAnim.restart();
        }

        NumberAnimation on y {
            id: yAnim
            duration: 200; easing.type: Easing.InOutCubic

            // Set binding so that screen resizes affect Y
            onFinished: {
                launcherHomeColumn.y = Qt.binding(() => launcherHomeColumn.intendedY())
            }
        }

        spacing: Kirigami.Units.largeSpacing * 3

        Bigscreen.TileListView {
            id: favAppsView
            // Recursively get the next visible view
            property var currentViewUpwards: visible ? favAppsView : root.navigationUp
            property var currentViewDownwards: visible ? favAppsView : recentView.currentViewDownwards

            title: i18n("Favorites")
            model: plasmoid.favsListModel
            visible: count > 0
            currentIndex: 0
            focus: visible
            onActiveFocusChanged: if (activeFocus) launcherHomeColumn.currentSection = favAppsView
            delegate: Delegates.FavDelegate {
                property var modelData: typeof model !== "undefined" ? model : null
            }

            navigationUp: root.navigationUp
            navigationDown: recentView.currentViewDownwards
        }

        Bigscreen.TileListView {
            id: recentView
            property var currentViewUpwards: visible ? recentView : favAppsView.currentViewUpwards
            property var currentViewDownwards: visible ? recentView : voiceAppsView.currentViewDownwards

            title: i18n("Recent")
            model: Kicker.RecentUsageModel {
                shownItems: Kicker.RecentUsageModel.OnlyApps
            }

            visible: count > 0
            currentIndex: 0
            focus: visible && (favAppsView.currentViewUpwards === root.navigationUp)
            onActiveFocusChanged: if (activeFocus) launcherHomeColumn.currentSection = recentView

            delegate: Delegates.AppDelegate {
                property real sectionOpacity: 1.0
                property var modelData: typeof model !== "undefined" ? model : null
                iconImage: model.decoration
                text: model.display
                onClicked: (mouse) => {
                    recentView.model.trigger(index, "", null);
                }
            }

            navigationUp: favAppsView.currentViewUpwards
            navigationDown: voiceAppsView.currentViewDownwards
        }

        Bigscreen.TileListView {
            id: voiceAppsView
            property var currentViewUpwards: visible ? voiceAppsView : recentView.currentViewUpwards
            property var currentViewDownwards: visible ? voiceAppsView : appsView.currentViewDownwards

            title: i18n("Voice Applications")
            model: KItemModels.KSortFilterProxyModel {
                sourceModel: plasmoid.applicationListModel
                filterRoleName: "ApplicationCategoriesRole"
                filterRowCallback: function(source_row, source_parent) {
                    return sourceModel.data(sourceModel.index(source_row, 0, source_parent), ApplicationListModel.ApplicationCategoriesRole).indexOf("VoiceApp") !== -1;
                }
            }

            visible: count > 0
            enabled: count > 0
            currentIndex: 0
            focus: visible && (recentView.currentViewUpwards === root.navigationUp)
            onActiveFocusChanged: if (activeFocus) launcherHomeColumn.currentSection = voiceAppsView
            delegate: Delegates.VoiceAppDelegate {
                property var modelData: typeof model !== "undefined" ? model : null
            }

            navigationUp: recentView.currentViewUpwards
            navigationDown: appsView.currentViewDownwards
        }

        Bigscreen.TileListView {
            id: appsView
            property var currentViewUpwards: visible ? appsView : voiceAppsView.currentViewUpwards
            property var currentViewDownwards: visible ? appsView : gamesView.currentViewDownwards

            title: i18n("Applications")
            visible: count > 0
            enabled: count > 0
            model: KItemModels.KSortFilterProxyModel {
                sourceModel: plasmoid.applicationListModel
                filterRoleName: "ApplicationCategoriesRole"
                filterRowCallback: function(source_row, source_parent) {
                    var cats = sourceModel.data(sourceModel.index(source_row, 0, source_parent), ApplicationListModel.ApplicationCategoriesRole);
                    return cats.indexOf("Game") === -1 && cats.indexOf("VoiceApp") === -1;
                }
            }

            currentIndex: 0
            focus: visible && (voiceAppsView.currentViewUpwards === root.navigationUp)
            onActiveFocusChanged: if (activeFocus) launcherHomeColumn.currentSection = appsView
            delegate: Delegates.AppDelegate {
                property var modelData: typeof model !== "undefined" ? model : null
            }

            navigationUp: voiceAppsView.currentViewUpwards
            navigationDown: gamesView.currentViewDownwards
        }

        Bigscreen.TileListView {
            id: gamesView
            property var currentViewUpwards: visible ? gamesView : appsView.currentViewUpwards
            property var currentViewDownwards: visible ? gamesView : settingsView.currentViewDownwards

            title: i18n("Games")
            visible: count > 0
            enabled: count > 0
            model: KItemModels.KSortFilterProxyModel {
                sourceModel: plasmoid.applicationListModel
                filterRoleName: "ApplicationCategoriesRole"
                filterRowCallback: function(source_row, source_parent) {
                    return sourceModel.data(sourceModel.index(source_row, 0, source_parent), ApplicationListModel.ApplicationCategoriesRole).indexOf("Game") !== -1;
                }
            }

            currentIndex: 0
            focus: visible && (appsView.currentViewUpwards === root.navigationUp)
            onActiveFocusChanged: if (activeFocus) launcherHomeColumn.currentSection = gamesView
            delegate: Delegates.AppDelegate {
                property var modelData: typeof model !== "undefined" ? model : null
            }

            navigationUp: appsView.currentViewUpwards
            navigationDown: settingsView.currentViewDownwards
        }

        SettingActions {
            id: settingActions
        }

        Bigscreen.TileListView {
            id: settingsView
            property var currentViewUpwards: visible ? settingsView : gamesView.currentViewUpwards
            property var currentViewDownwards: visible ? settingsView : null

            title: i18n("Settings")
            model: plasmoid.kcmsListModel

            currentIndex: 0
            onActiveFocusChanged: if (activeFocus) launcherHomeColumn.currentSection = settingsView
            delegate: Delegates.SettingDelegate {
                property var modelData: typeof model !== "undefined" ? model : null
            }

            navigationUp: gamesView.currentViewUpwards
            navigationDown: null
        }

        Component.onCompleted: {
            if (recentView.visible) {
                recentView.forceActiveFocus();
            } else if(voiceAppsView.visible) {
                voiceAppsView.forceActiveFocus();
            } else {
                appsView.forceActiveFocus();
            }
        }

        Connections {
            target: root
            function onActivateAppView() {
                if (recentView.visible) {
                recentView.forceActiveFocus();
                } else if(voiceAppsView.visible) {
                    voiceAppsView.forceActiveFocus();
                } else {
                    appsView.forceActiveFocus();
                }
            }
        }
    }
}
