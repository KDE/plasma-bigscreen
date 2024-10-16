/*
    SPDX-FileCopyrightText: 2020 Aditya Mehra <aix.m@outlook.com>

    SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL

*/

import QtQuick.Layouts
import QtQuick
import QtQuick.Window
import QtQuick.Controls
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import org.kde.bigscreen as BigScreen
import "delegates" as Delegates

KCM.SimpleKCM {
    id: root

    title: i18n("Appearance")
    background: null
    leftPadding: Kirigami.Units.smallSpacing
    topPadding: 0
    rightPadding: Kirigami.Units.smallSpacing
    bottomPadding: 0

    property Item settingMenuItem: root.parent.parent.lastSettingMenuItem

    function settingMenuItemFocus() {
        settingMenuItem.forceActiveFocus()
    }

    Component.onCompleted: {
        desktopThemeView.forceActiveFocus();
    }

    function setOption(type, result){
        if(type == "coloredTile"){
            kcm.setUseColoredTiles(result);
        }
        if(type == "exapandableTile"){
            kcm.setUseExpandingTiles(result);
        }
        if(type == "pmInhibition"){
            kcm.setPmInhibitionActive(result);
        }
    }

    contentItem: FocusScope {

        Item {
            id: headerAreaTop
            height: parent.height * 0.075
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: Kirigami.Units.largeSpacing

            Kirigami.Heading {
                id: settingsTitle
                text: i18n("Appearance & Personalization")
                anchors.fill: parent
                anchors.margins: Kirigami.Units.largeSpacing
                verticalAlignment: Text.AlignBottom
                horizontalAlignment: Text.AlignLeft
                font.bold: true
                color: Kirigami.Theme.textColor
                fontSizeMode: Text.Fit
                minimumPixelSize: 16
                font.pixelSize: 32
            }
        }

        Kirigami.Separator {
            id: settingsSeparator
            anchors.top: headerAreaTop.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            Kirigami.Theme.colorSet: Kirigami.Theme.Button
            Kirigami.Theme.inherit: false
            color: Kirigami.Theme.backgroundColor
            height: 2
        }

        Item {
            anchors.left: parent.left
            anchors.leftMargin: Kirigami.Units.largeSpacing
            anchors.top: headerAreaTop.bottom
            anchors.topMargin: Kirigami.Units.largeSpacing * 2
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.rightMargin: Kirigami.Units.largeSpacing
            clip: true

            ColumnLayout {
                id: contentLayout
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: Kirigami.Units.largeSpacing
                anchors.rightMargin: Kirigami.Units.largeSpacing

                Behavior on y {
                    NumberAnimation {
                        duration: Kirigami.Units.longDuration * 2
                        easing.type: Easing.InOutQuad
                    }
                }

                Kirigami.Heading {
                    id: launcherLookHeader
                    text: i18n("Launcher Appearance")
                    color: Kirigami.Theme.textColor
                }

                Delegates.LocalSettingDelegate {
                    id: pmInhibitionDelegate
                    Layout.fillWidth: true
                    Layout.preferredHeight: Kirigami.Units.gridUnit * 4
                    isChecked: kcm.pmInhibitionActive() ? 1 : 0
                    name: i18n("Power Inhibition")
                    customType: "pmInhibition"
                    KeyNavigation.left: settingMenuItem
                    KeyNavigation.down: coloredTileDelegate
                }

                Delegates.LocalSettingDelegate {
                    id: coloredTileDelegate
                    Layout.fillWidth: true
                    Layout.preferredHeight: Kirigami.Units.gridUnit * 4
                    isChecked: kcm.useColoredTiles() ? 1 : 0
                    name: i18n("Colored Tiles")
                    customType: "coloredTile"
                    KeyNavigation.left: settingMenuItem
                    KeyNavigation.up: pmInhibitionDelegate
                    KeyNavigation.down: expandableTileDelegate
                }

                Delegates.LocalSettingDelegate {
                    id: expandableTileDelegate
                    Layout.fillWidth: true
                    Layout.preferredHeight: Kirigami.Units.gridUnit * 4
                    isChecked: kcm.useExpandingTiles() ? 1 : 0
                    name: i18n("Expanding Tiles")
                    customType: "exapandableTile"
                    KeyNavigation.left: settingMenuItem
                    KeyNavigation.up: coloredTileDelegate
                    KeyNavigation.down: timeDateSettingsDelegate
                }

                Delegates.TimeDelegate {
                    id: timeDateSettingsDelegate
                    Layout.fillWidth: true
                    Layout.preferredHeight: Kirigami.Units.gridUnit * 4
                    name: i18n("Adjust Date & Time")
                    KeyNavigation.left: settingMenuItem
                    KeyNavigation.up: expandableTileDelegate
                    KeyNavigation.down: settingsShortcutDelegate
                }

                Kirigami.Heading {
                    id: launcherShortcutsHeader
                    text: i18n("Bigscreen Shortcuts")
                    color: Kirigami.Theme.textColor
                }

                Delegates.ShortcutsDelegate {
                    id: settingsShortcutDelegate
                    Layout.fillWidth: true
                    Layout.preferredHeight: Kirigami.Units.gridUnit * 4
                    description: i18n("Bigscreen Settings Shortcut")
                    getActionPath: "activateSettingsShortcut"
                    setActionPath: "setActivateSettingsShortcut"
                    KeyNavigation.left: settingMenuItem
                    KeyNavigation.up: timeDateSettingsDelegate
                    KeyNavigation.down: tasksShortcutDelegate
                }

                Delegates.ShortcutsDelegate {
                    id: tasksShortcutDelegate
                    Layout.fillWidth: true
                    Layout.preferredHeight: Kirigami.Units.gridUnit * 4
                    description: i18n("Bigscreen Tasks Shortcut")
                    getActionPath: "activateTasksShortcut"
                    setActionPath: "setActivateTasksShortcut"
                    KeyNavigation.left: settingMenuItem
                    KeyNavigation.up: settingsShortcutDelegate
                    KeyNavigation.down: displayHomeScreenShortcutDelegate
                }

                Delegates.ShortcutsDelegate {
                    id: displayHomeScreenShortcutDelegate
                    Layout.fillWidth: true
                    Layout.preferredHeight: Kirigami.Units.gridUnit * 4
                    description: i18n("Bigscreen Display Homescreen Shortcut")
                    getActionPath: "displayHomeScreenShortcut"
                    setActionPath: "setDisplayHomeScreenShortcut"
                    KeyNavigation.left: settingMenuItem
                    KeyNavigation.up: tasksShortcutDelegate
                    KeyNavigation.down: desktopThemeView
                }

                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Kirigami.Units.largeSpacing * 2
                }

                BigScreen.TileView {
                    id: desktopThemeView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignTop
                    focus: true
                    model: kcm.globalThemeListModel
                    view.cacheBuffer: parent.width * 2
                    title: i18n("General Appearance")
                    navigationUp: displayHomeScreenShortcutDelegate
                    enabled: !settingsAreaLoader.opened
                    delegate: Delegates.ThemeDelegate {
                        text: model.display
                    }

                    Behavior on x {
                        NumberAnimation {
                            duration: Kirigami.Units.longDuration * 2
                            easing.type: Easing.InOutQuad
                        }
                    }
                }
            }
        }

        SettingsAreaLoader {
            id: settingsAreaLoader
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.rightMargin: -Kirigami.Units.smallSpacing
            property bool opened: false
            visible: opened
            enabled: opened
            width: parent.width / 3.5

            onOpenedChanged: {
                if(opened){
                    settingsAreaLoader.forceActiveFocus()
                }
            }
        }
    }
}

