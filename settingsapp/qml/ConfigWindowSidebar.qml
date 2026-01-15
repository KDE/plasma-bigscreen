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

            delegate: Controls.Button {
                id: kcmButton
                property var modelData: typeof model !== "undefined" ? model : null

                width: settingsKCMMenu.width - settingsKCMMenu.leftMargin - settingsKCMMenu.rightMargin

                leftPadding: Kirigami.Units.gridUnit * 2
                rightPadding: Kirigami.Units.gridUnit * 2
                topPadding: Kirigami.Units.largeSpacing
                bottomPadding: Kirigami.Units.largeSpacing

                onClicked: openModule(modelData.kcmId);
                Keys.onReturnPressed: openModule(modelData.kcmId);

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

                background: Rectangle {
                    id: kcmButtonBackground
                    color: (modelData.kcmId == currentModuleName) ?
                            Qt.rgba(Kirigami.Theme.highlightColor.r, Kirigami.Theme.highlightColor.g, Kirigami.Theme.highlightColor.b, 0.2) :
                            (kcmButton.hovered ? Qt.rgba(Kirigami.Theme.highlightColor.r, Kirigami.Theme.highlightColor.g, Kirigami.Theme.highlightColor.b, 0.1)
                                : 'transparent')
                    radius: Kirigami.Units.cornerRadius

                    Kirigami.Theme.inherit: false
                    Kirigami.Theme.colorSet: Kirigami.Theme.Button

                    border.width: 2
                    border.color: {
                        if (modelData.kcmId === currentModuleName) {
                            return Kirigami.Theme.highlightColor;
                        } else if (kcmButton.ListView.isCurrentItem && settingsKCMMenu.activeFocus) {
                            return Kirigami.Theme.highlightColor;
                        }
                        return 'transparent';
                    }

                    // Only scale if this delegate is the shown KCM, and user focus is on it
                    scale: (modelData.kcmId == currentModuleName && kcmButton.ListView.isCurrentItem && settingsKCMMenu.activeFocus) ? 1.05 : 1
                    Behavior on scale { NumberAnimation {} }
                }

                contentItem: RowLayout {
                    id: kcmButtonLayout
                    spacing: Kirigami.Units.gridUnit

                    Kirigami.Icon {
                        id: kcmButtonIcon
                        source: modelData.kcmIconName
                        Layout.alignment: Qt.AlignLeft
                        Layout.preferredHeight: Kirigami.Units.iconSizes.medium
                        Layout.preferredWidth: kcmButtonIcon.height
                    }

                    Kirigami.Heading {
                        id: kcmButtonLabel
                        text: modelData.kcmName
                        wrapMode: Text.Wrap
                        elide: Text.ElideRight
                        font.weight: Font.Medium
                        Layout.fillWidth: true
                    }
                }
            }
        }
    }
}
