/*
    SPDX-FileCopyrightText: 2019 Aditya Mehra <aix.m@outlook.com>
    SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.14
import QtQuick.Layouts 1.14
import QtQuick.Controls 2.14 as Controls
import QtQuick.Window 2.14
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.kquickcontrolsaddons 2.0
import org.kde.kirigami 2.12 as Kirigami
import org.kde.kitemmodels 1.0 as KItemModels

import "delegates" as Delegates
import org.kde.mycroft.bigscreen 1.0 as BigScreen
import org.kde.private.biglauncher 1.0 
import org.kde.plasma.private.kicker 0.1 as Kicker

FocusScope {
    property bool mycroftIntegration: plasmoid.nativeInterface.bigLauncherDbusAdapterInterface.mycroftIntegraionActive() ? 1 : 0

    Connections {
        target: plasmoid.nativeInterface.bigLauncherDbusAdapterInterface

        onEnableMycroftIntegraionChanged: {
            mycroftIntegration = plasmoid.nativeInterface.bigLauncherDbusAdapterInterface.mycroftIntegraionActive()
            if(mycroftIntegration){
                voiceAppsView.visible = voiceAppsView.count > 0 ? 1 : 0
            } else {
                voiceAppsView.visible = false
            }
        }
    }

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
        spacing: Kirigami.Units.largeSpacing*3
        

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
                property var modelData: typeof model !== "undefined" ? model : null
                iconImage: model.decoration
                text: model.display
                comment: model.description
                onClicked: recentView.model.trigger(index, "", null);
            }

            navigationUp: shutdownIndicator
            navigationDown: voiceAppsView.visible ? voiceAppsView : appsView
        }

        BigScreen.TileRepeater {
            id: voiceAppsView
            title: i18n("Voice Apps")
            compactMode: plasmoid.configuration.expandingTiles
            model: KItemModels.KSortFilterProxyModel {
                sourceModel: plasmoid.nativeInterface.applicationListModel
                filterRole: "ApplicationCategoriesRole"
                filterRowCallback: function(source_row, source_parent) {
                    return sourceModel.data(sourceModel.index(source_row, 0, source_parent), ApplicationListModel.ApplicationCategoriesRole).indexOf("VoiceApp") !== -1;
                }
            }

            visible: mycroftIntegration && count > 0
            currentIndex: 0
            focus: false
            onActiveFocusChanged: if (activeFocus) launcherHomeColumn.currentSection = voiceAppsView
            delegate: Delegates.VoiceAppDelegate {
                property var modelData: typeof model !== "undefined" ? model : null
                
            }

            navigationUp: recentView.visible ? recentView : shutdownIndicator
            navigationDown: appsView
        }

        BigScreen.TileRepeater {
            id: appsView
            title: i18n("Applications")
            compactMode: plasmoid.configuration.expandingTiles
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
            
            navigationUp: voiceAppsView.visible ? voiceAppsView : recentView.visible ? recentView : shutdownIndicator
            navigationDown: gamesView
        }
        
        BigScreen.TileRepeater {
            id: gamesView
            title: i18n("Games")
            compactMode: plasmoid.configuration.expandingTiles
            model: KItemModels.KSortFilterProxyModel {
                sourceModel: plasmoid.nativeInterface.applicationListModel
                filterRole: "ApplicationCategoriesRole"
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
            
            navigationUp: appsView
            navigationDown: settingsView
        }
        
        BigScreen.TileRepeater {
            id: settingsView
            title: i18n("Settings")
            model: actions
            compactMode: plasmoid.configuration.expandingTiles

            property list<Controls.Action> actions: [
                Controls.Action {
                    text: i18n("Audio")
                    icon.name: "audio-volume-high"
                    onTriggered: plasmoid.nativeInterface.executeCommand("plasma-settings -s -m kcm_audiodevice")
                    property bool active: true
                },
                Controls.Action {
                    text: i18n("Bigscreen Settings")
                    icon.name: "view-grid-symbolic"
                    onTriggered: plasmoid.nativeInterface.executeCommand("plasma-settings -s -m kcm_mediacenter_bigscreen_settings")
                    property bool active: true
                },
                Controls.Action {
                    text: i18n("Mycroft Skill Installer")
                    icon.name: "download"
                    onTriggered: plasmoid.nativeInterface.executeCommand("MycroftSkillInstaller")
                    property bool active: mycroftIntegration
                },
                Controls.Action {
                    text: i18n("Wallpaper")
                    icon.name: "preferences-desktop-wallpaper"
                    onTriggered: plasmoid.action("configure").trigger();
                    property bool active: true
                },
                Controls.Action {
                    text: i18n("Wireless")
                    icon.name: "network-wireless-connected-100"
                    onTriggered: plasmoid.nativeInterface.executeCommand("plasma-settings -s -m kcm_mediacenter_wifi")
                    property bool active: true
                },
                Controls.Action {
                    text: i18n("KDE Connect")
                    icon.name: "kdeconnect"
                    onTriggered: plasmoid.nativeInterface.executeCommand("plasma-settings -s -m kcm_mediacenter_kdeconnect")
                    property bool active: true
                }
            ]

            onActiveFocusChanged: if (activeFocus) launcherHomeColumn.currentSection = settingsView
            delegate: Delegates.SettingDelegate {
                property var modelData: typeof model !== "undefined" ? model : null
                visible: model.active
            }
            
            navigationUp: gamesView
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
            onActivateAppView: {
                voiceAppsView.forceActiveFocus();
            }
        }
    }
}

