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
import org.kde.bigscreen as Bigscreen
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
        coloredTileDelegate.forceActiveFocus();
    }

    function setOption(type, result){
        if(type == "coloredTile"){
            kcm.setUseColoredTiles(result);
        }
        if(type == "pmInhibition"){
            kcm.setPmInhibitionActive(result);
        }
    }

    contentItem: FocusScope {
        Item {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.topMargin: Kirigami.Units.largeSpacing * 2
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.rightMargin: Kirigami.Units.largeSpacing
            clip: true
            KeyNavigation.left: settingMenuItemFocus()

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
                    text: i18n("Home Screen Appearance")
                    color: Kirigami.Theme.textColor
                }

                Delegates.LocalSettingDelegate {
                    id: coloredTileDelegate
                    Layout.fillWidth: true
                    isChecked: kcm.useColoredTiles() ? 1 : 0
                    name: i18n("Colored Tiles")
                    description: i18n("Tile backgrounds will be colored based on the app's icon")
                    customType: "coloredTile"
                    KeyNavigation.up: pmInhibitionDelegate
                    KeyNavigation.down: desktopThemeView
                }

                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Kirigami.Units.largeSpacing * 2
                }

                Bigscreen.TileView {
                    id: desktopThemeView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignTop
                    focus: true
                    model: kcm.globalThemeListModel
                    view.cacheBuffer: parent.width * 2
                    title: i18n("Global Theme")
                    navigationUp: coloredTileDelegate
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

