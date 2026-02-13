// SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
// SPDX-FileCopyrightText: 2019 Aditya Mehra <aix.m@outlook.com>
// SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Window
import QtQuick.Controls as Controls

import org.kde.kirigami as Kirigami
import org.kde.bigscreen as Bigscreen

import org.kde.plasma.bigscreen.settings

Rectangle {
    id: root

    property string currentModuleName
    property real headerHeight

    property var listView: settingsKCMMenu

    readonly property real horizontalMargin: Kirigami.Units.gridUnit + Kirigami.Units.largeSpacing

    // Translucent background
    color: Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 0.8)

    width: Math.max(Kirigami.Units.gridUnit * 20, parent.width * 0.20)
    height: parent.height

    ColumnLayout {
        anchors.fill: parent

        // Header
        Item {
            id: settingsHeader
            Layout.fillWidth: true
            Layout.preferredHeight: root.headerHeight

            Kirigami.Heading {
                id: settingsTitle
                text: i18n("Settings")
                anchors.fill: parent

                padding: root.horizontalMargin
                verticalAlignment: Text.AlignBottom
                horizontalAlignment: Text.AlignLeft

                font.weight: Font.Light

                color: Kirigami.Theme.textColor
                fontSizeMode: Text.Fit
                minimumPixelSize: 16
                font.pixelSize: 32
            }
        }

        // Settings module list
        ListView {
            id: settingsKCMMenu

            Layout.fillWidth: true
            Layout.fillHeight: true
            leftMargin: root.horizontalMargin
            rightMargin: root.horizontalMargin
            topMargin: Kirigami.Units.largeSpacing
            bottomMargin: Kirigami.Units.largeSpacing

            model: KcmsListModel
            spacing: Kirigami.Units.largeSpacing
            keyNavigationEnabled: true

            onCurrentItemChanged: {
                if (currentItem) {
                    currentItem.forceActiveFocus();
                }

                Bigscreen.NavigationSoundEffects.playMovingSound();
            }

            Bigscreen.Dialog {
                id: desktopSettingsDialog
                title: i18n("Open desktop settings?")
                standardButtons: Bigscreen.Dialog.Ok | Bigscreen.Dialog.Cancel

                contentItem: Controls.Label {
                    font.pixelSize: Bigscreen.Units.defaultFontPixelSize
                    text: i18n("The desktop settings application does not support key navigation, a mouse may be required. However, it contains extra settings that may be useful.")
                    wrapMode: Text.Wrap
                }

                onAccepted: SettingsApp.openDesktopSettings();
            }

            delegate: SidebarDelegate {
                id: kcmButton
                property var modelData: typeof model !== "undefined" ? model : null

                width: settingsKCMMenu.width - settingsKCMMenu.leftMargin - settingsKCMMenu.rightMargin

                onClicked: open()
                Keys.onReturnPressed: open()

                function open() {
                    if (modelData.kcmId === "open-desktop-settings") {
                        // Custom "fake" KCM to open the desktop settings
                        desktopSettingsDialog.open();
                        return;
                    }

                    openModule(modelData.kcmId);
                }

                // Need a timer for listview to propagate model changes, otherwise the last kcm (ex. Wi-Fi) doesn't get selected
                Timer {
                    id: indexChangeTimer
                    interval: 1
                    repeat: false
                    onTriggered: {
                        if (modelData.kcmId === currentModuleName) {
                            settingsKCMMenu.currentIndex = model.index;
                        }
                    }
                }

                Component.onCompleted: indexChangeTimer.restart();
                Connections {
                    target: root
                    function onCurrentModuleNameChanged() {
                        indexChangeTimer.restart();
                    }
                }

                name: modelData.kcmName
                iconName: modelData.kcmIconName
                selected: modelData.kcmId === currentModuleName
            }
        }
    }
}
