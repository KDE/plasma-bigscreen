/*
    SPDX-FileCopyrightText: 2020 Aditya Mehra <aix.m@outlook.com>
    SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>

    SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL

*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Window
import QtQuick.Controls as QQC2

import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import org.kde.bigscreen as Bigscreen

Kirigami.ScrollablePage {
    id: root

    title: i18n("System")
    background: null

    leftPadding: Kirigami.Units.smallSpacing
    topPadding: Kirigami.Units.smallSpacing
    rightPadding: Kirigami.Units.smallSpacing
    bottomPadding: Kirigami.Units.smallSpacing

    onActiveFocusChanged: {
        if (activeFocus) {
            coloredTileDelegate.forceActiveFocus();
        }
    }

    ColumnLayout {
        // Since ScrollablePage's scrollview eats up the propagation of the left event to root, manually set it here
        KeyNavigation.left: root.KeyNavigation.left
        spacing: 0

        QQC2.Label {
            text: i18n("Homescreen Appearance")
            font.pixelSize: 22

            Layout.topMargin: Kirigami.Units.gridUnit
            Layout.bottomMargin: Kirigami.Units.gridUnit
        }

        Bigscreen.SwitchDelegate {
            id: coloredTileDelegate
            Layout.bottomMargin: Kirigami.Units.smallSpacing

            raisedBackground: true
            checked: kcm.useColoredTiles() ? 1 : 0
            text: i18n("Colored tiles")
            description: i18n("Tile backgrounds will be colored based on the app's icon")

            KeyNavigation.down: wallpaperBlurDelegate

            onCheckedChanged: kcm.setUseColoredTiles(checked);
        }

        Bigscreen.SwitchDelegate {
            id: wallpaperBlurDelegate
            Layout.bottomMargin: Kirigami.Units.smallSpacing

            raisedBackground: true
            checked: kcm.useWallpaperBlur() ? 1 : 0
            text: i18n("Wallpaper blur")
            description: i18n("Apply a blur effect to the wallpaper on the homescreen")

            KeyNavigation.down: desktopThemeButton

            onCheckedChanged: kcm.setUseWallpaperBlur(checked);
        }

        Bigscreen.ButtonDelegate {
            id: desktopThemeButton
            raisedBackground: true

            KeyNavigation.down: pmInhibitionDelegate

            text: i18n("Global theme")
            description: i18n("Set the system theme")

            onClicked: themeSidebar.open();
        }

        QQC2.Label {
            text: i18n("System")
            font.pixelSize: 22

            Layout.topMargin: Kirigami.Units.gridUnit
            Layout.bottomMargin: Kirigami.Units.gridUnit
        }

        Bigscreen.SwitchDelegate {
            id: pmInhibitionDelegate
            Layout.bottomMargin: Kirigami.Units.smallSpacing
            KeyNavigation.down: timeDateDelegate

            text: i18n("Power inhibition")
            checked: kcm.pmInhibitionActive() ? true : false
            onCheckedChanged: kcm.setPmInhibitionActive(checked);
        }

        Bigscreen.ButtonDelegate {
            id: timeDateDelegate
            KeyNavigation.down: settingsShortcutDelegate

            icon.name: "preferences-system-time"
            text: i18n("Adjust date & time")

            onClicked: deviceTimeSettings.open()
        }

        QQC2.Label {
            text: i18n("Shortcuts")
            font.pixelSize: 22

            Layout.topMargin: Kirigami.Units.gridUnit
            Layout.bottomMargin: Kirigami.Units.gridUnit
        }

        Bigscreen.ButtonDelegate {
            id: settingsShortcutDelegate
            KeyNavigation.down: tasksShortcutDelegate
            Layout.bottomMargin: Kirigami.Units.smallSpacing
            text: i18n("Open settings shortcut")
            icon.name: 'preferences-desktop-keyboard-symbolic'

            property string getActionPath: "activateSettingsShortcut"
            property string setActionPath: "setActivateSettingsShortcut"
            property string resetActionPath: "resetActivateSettingsShortcut"
            onClicked: {
                shortcutsPicker.title = text;
                shortcutsPicker.currentShortcut = kcm.getShortcut(getActionPath);
                shortcutsPicker.getActionPath = getActionPath;
                shortcutsPicker.setActionPath = setActionPath;
                shortcutsPicker.resetActionPath = resetActionPath;
                shortcutsPicker.open();
            }
        }

        Bigscreen.ButtonDelegate {
            id: tasksShortcutDelegate
            KeyNavigation.down: homescreenShortcutDelegate
            Layout.bottomMargin: Kirigami.Units.smallSpacing
            text: i18n("Open tasks shortcut")
            icon.name: 'preferences-desktop-keyboard-symbolic'

            property string getActionPath: "activateTasksShortcut"
            property string setActionPath: "setActivateTasksShortcut"
            property string resetActionPath: "resetActivateTasksShortcut"
            onClicked: {
                shortcutsPicker.title = text;
                shortcutsPicker.currentShortcut = kcm.getShortcut(getActionPath);
                shortcutsPicker.getActionPath = getActionPath;
                shortcutsPicker.setActionPath = setActionPath;
                shortcutsPicker.resetActionPath = resetActionPath;
                shortcutsPicker.open();
            }
        }

        Bigscreen.ButtonDelegate {
            id: homescreenShortcutDelegate
            Layout.bottomMargin: Kirigami.Units.smallSpacing
            text: i18n("Open homescreen shortcut")
            icon.name: 'preferences-desktop-keyboard-symbolic'

            property string getActionPath: "displayHomeScreenShortcut"
            property string setActionPath: "setDisplayHomeScreenShortcut"
            property string resetActionPath: "resetDisplayHomeScreenShortcut"
            onClicked: {
                shortcutsPicker.title = text;
                shortcutsPicker.currentShortcut = kcm.getShortcut(getActionPath);
                shortcutsPicker.getActionPath = getActionPath;
                shortcutsPicker.setActionPath = setActionPath;
                shortcutsPicker.resetActionPath = resetActionPath;
                shortcutsPicker.open();
            }
        }

        ShortcutsPickerSidebar {
            id: shortcutsPicker
            onClosed: settingsShortcutDelegate.forceActiveFocus()
        }

        DeviceTimeSettingsSidebar {
            id: deviceTimeSettings
            onClosed: timeDateDelegate.forceActiveFocus()
        }

        ThemeSidebar {
            id: themeSidebar
            onClosed: desktopThemeButton.forceActiveFocus()
        }
    }
}

