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
import org.kde.bigscreen 1.0 as BigScreen
import org.kde.private.biglauncher 1.0 
import org.kde.plasma.private.kicker 0.1 as Kicker

FocusScope {
    anchors {
        fill: parent
        leftMargin: Kirigami.Units.largeSpacing * 4
        topMargin: Kirigami.Units.largeSpacing * 3
    }

    ColumnLayout {
        id: launcherHomeColumn
        anchors {
            left: parent.left
            right: parent.right
        }
        property Item currentSection

        y: currentSection ? -currentSection.y + parent.height/2 - currentSection.height/2 : parent.height/2

        Behavior on y {
            YAnimator {
                duration: Kirigami.Units.longDuration * 2
                easing.type: Easing.InOutQuad
                
            }
        }
        //height: parent.height
        spacing: Kirigami.Units.largeSpacing * 3

 
        BigScreen.TileRepeater {
            id: favAppsView
            title: i18n("Favorites")
            model: plasmoid.favsListModel
            visible: count > 0
            currentIndex: 0
            focus: false
            columns: 7
            onActiveFocusChanged: if (activeFocus) launcherHomeColumn.currentSection = favAppsView
            delegate: Delegates.FavDelegate {
                property var modelData: typeof model !== "undefined" ? model : null
            }

            navigationUp: shutdownIndicator
            navigationDown: recentView.visible ? recentView : voiceAppsView.visible ? voiceAppsView : appsView.visible ? appsView : gamesView.visible ? gamesView : settingsView
        }
    
        
        BigScreen.TileRepeater {
            id: recentView
            title: i18n("Recent")
            compactMode: plasmoid.configuration.expandingTiles
            model: Kicker.RecentUsageModel {
                shownItems: Kicker.RecentUsageModel.OnlyApps
            }

            visible: count > 0
            currentIndex: 0
            focus: true
            onActiveFocusChanged: if (activeFocus) launcherHomeColumn.currentSection = recentView

            delegate: Delegates.AppDelegate {
                property real sectionOpacity: 1.0
                property var modelData: typeof model !== "undefined" ? model : null
                iconImage: model.decoration
                text: model.display
                comment: model.description
                onClicked: (mouse)=> {
                    recentView.model.trigger(index, "", null);
                }
            }

            navigationUp: favAppsView.visible ? favAppsView : shutdownIndicator
            navigationDown: voiceAppsView.visible ? voiceAppsView : appsView.visible ? appsView : gamesView.visible ? gamesView : settingsView
        }

        BigScreen.TileRepeater {
            id: voiceAppsView
            title: i18n("Voice Applications")
            compactMode: plasmoid.configuration.expandingTiles
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
            focus: false
            onActiveFocusChanged: if (activeFocus) launcherHomeColumn.currentSection = voiceAppsView
            delegate: Delegates.VoiceAppDelegate {
                property var modelData: typeof model !== "undefined" ? model : null
                
            }

            navigationUp: recentView.visible ? recentView : favAppsView.visible ? favAppsView : shutdownIndicator
            navigationDown: appsView.visible ? appsView : gamesView.visible ? gamesView : settingsView
        }

        BigScreen.TileRepeater {
            id: appsView
            title: i18n("Applications")
            compactMode: plasmoid.configuration.expandingTiles
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
            focus: false
            onActiveFocusChanged: if (activeFocus) launcherHomeColumn.currentSection = appsView
            delegate: Delegates.AppDelegate {
                property var modelData: typeof model !== "undefined" ? model : null
                comment: model.ApplicationCommentRole
            }
            
            navigationUp: voiceAppsView.visible ? voiceAppsView : recentView.visible ? recentView : favAppsView.visible ? favAppsView : shutdownIndicator
            navigationDown: gamesView.visible ? gamesView : settingsView
        }
        
        BigScreen.TileRepeater {
            id: gamesView
            title: i18n("Games")
            compactMode: plasmoid.configuration.expandingTiles
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
            focus: false
            onActiveFocusChanged: if (activeFocus) launcherHomeColumn.currentSection = gamesView
            delegate: Delegates.AppDelegate {
                property var modelData: typeof model !== "undefined" ? model : null
            }
            
            navigationUp: appsView.visible ? appsView : (voiceAppsView.visible ? voiceAppsView : (recentView.visible ? recentView : shutdownIndicator))
            navigationDown: settingsView
        }

        SettingActions {
            id: settingActions
        }
        
        BigScreen.TileRepeater {
            id: settingsView
            title: i18n("Settings")
            model: plasmoid.kcmsListModel
            compactMode: plasmoid.configuration.expandingTiles

            onActiveFocusChanged: if (activeFocus) launcherHomeColumn.currentSection = settingsView
            delegate: Delegates.SettingDelegate {
                property var modelData: typeof model !== "undefined" ? model : null
            }
            
            navigationUp: gamesView.visible ? gamesView : (appsView.visible ? appsView : (voiceAppsView.visible ? voiceAppsView : (recentView.visible ? recentView : favAppsView.visible ? favAppsView : shutdownIndicator)))
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
