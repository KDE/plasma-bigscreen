/*
 * Copyright 2019 Aditya Mehra <aix.m@outlook.com>
 * Copyright 2015 Marco Martin <mart@kde.org>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  2.010-1301, USA.
 */

import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3 as Controls
import QtQuick.Window 2.2
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.kquickcontrolsaddons 2.0
import org.kde.private.biglauncher 1.0 as Launcher
import org.kde.kirigami 2.11 as Kirigami
import org.kde.kitemmodels 1.0 as KItemModels

import "delegates" as Delegates
import org.kde.mycroft.bigscreen 1.0 as BigScreen
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
        y: currentSection ? -currentSection.y : 0
        Behavior on y {
            YAnimator {
                duration: Kirigami.Units.longDuration * 2
                easing.type: Easing.InOutQuad
            }
        }
        height: parent.height
        spacing: Kirigami.Units.largeSpacing*3
        

        BigScreen.TileRepeater {
            id: recentView
            title: i18n("Recent Apps")
            model: Kicker.RecentUsageModel {
                shownItems: Kicker.RecentUsageModel.OnlyApps
            }

            visible: count > 0
            currentIndex: 0
            focus: true
            onActiveFocusChanged: if (activeFocus) launcherHomeColumn.currentSection = recentView
            delegate: Delegates.AppDelegate {
                property var modelData: typeof model !== "undefined" ? model : null
                iconImage: model.decoration
                text: model.display
                comment: model.description
                onClicked: recentView.model.trigger(index, "", null);
            }

            navigationUp: shutdownIndicator
            navigationDown: voiceAppsView
        }

        BigScreen.TileRepeater {
            id: voiceAppsView
            title: i18n("Voice Apps")
            model: KItemModels.KSortFilterProxyModel {
                sourceModel: plasmoid.nativeInterface.applicationListModel
                filterRole: "ApplicationCategoriesRole"
                filterRowCallback: function(source_row, source_parent) {
                    return sourceModel.data(sourceModel.index(source_row, 0, source_parent), ApplicationListModel.ApplicationCategoriesRole).indexOf("VoiceApp") !== -1;
                }
            }

            currentIndex: 0
            focus: false
            onActiveFocusChanged: if (activeFocus) launcherHomeColumn.currentSection = voiceAppsView
            delegate: Delegates.VoiceAppDelegate {
                property var modelData: typeof model !== "undefined" ? model : null
                
            }

            navigationUp: recentView
            navigationDown: appsView
        }

        BigScreen.TileRepeater {
            id: appsView
            title: i18n("Applications")
            model: KItemModels.KSortFilterProxyModel {
                sourceModel: plasmoid.nativeInterface.applicationListModel
                filterRole: "ApplicationCategoriesRole"
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
            
            navigationUp: voiceAppsView
            navigationDown: gamesView
        }
        
        BigScreen.TileRepeater {
            id: gamesView
            title: i18n("Games")
            model: KItemModels.KSortFilterProxyModel {
                sourceModel: plasmoid.nativeInterface.applicationListModel
                filterRole: "ApplicationCategoriesRole"
                filterRowCallback: function(source_row, source_parent) {
                    return sourceModel.data(sourceModel.index(source_row, 0, source_parent), ApplicationListModel.ApplicationCategoriesRole).indexOf("Game") !== -1;
                }
            }

            currentIndex: 0
            focus: false
            onActiveFocusChanged: if (activeFocus) launcherHomeColumn.currentSection = appsView
            delegate: Delegates.AppDelegate {
                property var modelData: typeof model !== "undefined" ? model : null
            }
            
            navigationUp: appsView
            navigationDown: settingsView
        }
        
        BigScreen.TileRepeater {
            id: settingsView
            title: i18n("Settings")
            model: actions

            property list<Controls.Action> actions: [
                Controls.Action {
                    text: i18n("Wireless")
                    icon.name: "network-wireless-connected-100"
                    onTriggered: plasmoid.nativeInterface.executeCommand("plasma-settings -s -m kcm_mediacenter_wifi")
                },
                Controls.Action {
                    text: i18n("Audio")
                    icon.name: "audio-volume-high"
                    onTriggered: plasmoid.nativeInterface.executeCommand("plasma-settings -s -m kcm_audiodevice")

                },
                Controls.Action {
                    text: i18n("Wallpaper")
                    icon.name: "preferences-desktop-wallpaper"
                    onTriggered: plasmoid.action("configure").trigger();
                },
                Controls.Action {
                    text: i18n("Mycroft Skill Installer")
                    icon.name: "download"
                    onTriggered: plasmoid.nativeInterface.executeCommand("MycroftSkillInstaller")
                }
            ]

            onActiveFocusChanged: if (activeFocus) launcherHomeColumn.currentSection = gamesView
            delegate: Delegates.SettingDelegate {
                property var modelData: typeof model !== "undefined" ? model : null
            }
            
            navigationUp: gamesView
            navigationDown: null
        }

        Component.onCompleted: {
            if (recentView.visible) {
                recentView.forceActiveFocus();
            } else {
                voiceAppsView.forceActiveFocus();
            }
        }

        Connections {
            target: root
            onActivateAppView: {
                voiceAppsView.forceActiveFocus();
            }
        }
    }
}

