/*
    SPDX-FileCopyrightText: 2020 Aditya Mehra <aix.m@outlook.com>

    SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL

*/

import QtQuick.Layouts 1.14
import QtQuick 2.14
import QtQuick.Window 2.14
import QtQuick.Controls 2.14
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import org.kde.bigscreen 1.0 as BigScreen
import "delegates" as Delegates

KCM.SimpleKCM {
    id: root

    title: i18n("Appearance")
    background: null
    leftPadding: Kirigami.Units.smallSpacing
    topPadding: 0
    rightPadding: Kirigami.Units.smallSpacing
    bottomPadding: 0

    Component.onCompleted: {
        desktopThemeView.forceActiveFocus();
    }

    function setTheme(packageName){
        kcm.themeName = packageName
    }

    function setOption(type, result){
        if(type == "coloredTile"){
            kcm.setUseColoredTiles(result);
        }
        if(type == "exapandableTile"){
            kcm.setUseExpandingTiles(result);
        }
        if(type == "mycroftIntegration"){
            kcm.setMycroftIntegrationActive(result);
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
            id: footerMain
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: -Kirigami.Units.largeSpacing
            anchors.bottom: parent.bottom
            implicitHeight: Kirigami.Units.gridUnit * 2

            Button {
                id: kcmcloseButton
                implicitHeight: Kirigami.Units.gridUnit * 2
                width: deviceTimeSettingsArea.opened ? (root.width + Kirigami.Units.largeSpacing) - deviceTimeSettingsArea.width : root.width + Kirigami.Units.largeSpacing
                KeyNavigation.up: desktopThemeView
                KeyNavigation.down: mycroftIntegrationDelegate

                background: Rectangle {
                    color: kcmcloseButton.activeFocus ? Kirigami.Theme.highlightColor : Kirigami.Theme.backgroundColor
                }

                contentItem: Item {
                    RowLayout {
                        anchors.centerIn: parent
                        Kirigami.Icon {
                            Layout.preferredWidth: Kirigami.Units.iconSizes.small
                            Layout.preferredHeight: Kirigami.Units.iconSizes.small
                            source: "window-close"
                        }
                        Label {
                            text: i18n("Exit")
                        }
                    }
                }

                onClicked: {
                    Window.window.close()
                }

                Keys.onReturnPressed: {
                    Window.window.close()
                }
            }
        }

        Item {
            anchors.left: parent.left
            anchors.leftMargin: Kirigami.Units.largeSpacing
            anchors.top: headerAreaTop.bottom
            anchors.topMargin: Kirigami.Units.largeSpacing * 2
            anchors.bottom: footerMain.top
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
                    layer.enabled: true
                    color: Kirigami.Theme.textColor
                }

                Delegates.LocalSettingDelegate {
                    id: pmInhibitionDelegate
                    Layout.fillWidth: true
                    Layout.preferredHeight: Kirigami.Theme.Units * 4
                    isChecked: kcm.pmInhibitionActive() ? 1 : 0
                    name: i18n("Power Inhibition")
                    customType: "pmInhibition"
                    KeyNavigation.up: kcmcloseButton
                    KeyNavigation.down: coloredTileDelegate
                }

                Delegates.LocalSettingDelegate {
                    id: coloredTileDelegate
                    Layout.fillWidth: true
                    Layout.preferredHeight: Kirigami.Theme.Units * 4
                    isChecked: kcm.useColoredTiles() ? 1 : 0
                    name: i18n("Colored Tiles")
                    customType: "coloredTile"
                    KeyNavigation.up: pmInhibitionDelegate
                    KeyNavigation.down: expandableTileDelegate
                }

                Delegates.LocalSettingDelegate {
                    id: expandableTileDelegate
                    Layout.fillWidth: true
                    Layout.preferredHeight: Kirigami.Theme.Units * 4
                    isChecked: kcm.useExpandingTiles() ? 1 : 0
                    name: i18n("Expanding Tiles")
                    customType: "exapandableTile"
                    KeyNavigation.up: coloredTileDelegate
                    KeyNavigation.down: timeDateSettingsDelegate
                }

                Delegates.TimeDelegate {
                    id: timeDateSettingsDelegate
                    Layout.fillWidth: true
                    Layout.preferredHeight: Kirigami.Theme.Units * 4
                    name: i18n("Adjust Date & Time")
                    KeyNavigation.up: expandableTileDelegate
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
                    model: kcm.themeListModel
                    view.cacheBuffer: parent.width * 2
                    title: i18n("General Appearance")
                    navigationUp: timeDateSettingsDelegate
                    navigationDown: kcmcloseButton
                    enabled: !deviceTimeSettingsArea.opened
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

        DeviceTimeSettings {
            id: deviceTimeSettingsArea
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.rightMargin: -Kirigami.Units.smallSpacing

            property bool opened: false

            width: parent.width / 3.5
            visible: opened
            enabled: opened
        }
    }
}

