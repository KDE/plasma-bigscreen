/*
    SPDX-FileCopyrightText: 2020 Aditya Mehra <aix.m@outlook.com>

    SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL

*/

import QtQuick.Layouts 1.14
import QtQuick 2.14
import QtQuick.Window 2.14
import QtQuick.Controls 2.14
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.kirigami 2.12 as Kirigami
import org.kde.kcm 1.2 as KCM
import org.kde.mycroft.bigscreen 1.0 as BigScreen
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

        Rectangle {
            id: headerAreaTop
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: -Kirigami.Units.largeSpacing
            anchors.rightMargin: -Kirigami.Units.largeSpacing
            height: parent.height * 0.075
            z: 10
            gradient: Gradient {
                GradientStop { position: 0.1; color: Qt.rgba(0, 0, 0, 0.5) }
                GradientStop { position: 0.9; color: Qt.rgba(0, 0, 0, 0.25) }
            }

            Kirigami.Heading {
                level: 1
                anchors.fill: parent
                anchors.topMargin: Kirigami.Units.largeSpacing
                anchors.leftMargin: Kirigami.Units.largeSpacing * 2
                anchors.bottomMargin: Kirigami.Units.largeSpacing
                color: Kirigami.Theme.textColor
                text: "Bigscreen Settings"
            }
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
                            Layout.preferredWidth: PlasmaCore.Units.iconSizes.small
                            Layout.preferredHeight: PlasmaCore.Units.iconSizes.small
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
            width: deviceTimeSettingsArea.opened ? parent.width - deviceTimeSettingsArea.width : parent.width
            clip: true

            ColumnLayout {
                id: contentLayout
                width: parent.width
                property Item currentSection
                y: currentSection ? (currentSection.y > parent.height / 2 ? -currentSection.y + Kirigami.Units.gridUnit * 3 : 0) : 0
                anchors.left: parent.left
                anchors.leftMargin: Kirigami.Units.largeSpacing

                Behavior on y {
                    NumberAnimation {
                        duration: Kirigami.Units.longDuration * 2
                        easing.type: Easing.InOutQuad
                    }
                }

                Kirigami.Heading {
                    id: launcherLookHeader
                    text: "Launcher Appearance"
                    layer.enabled: true
                    color: "white"
                }

                RowLayout {
                    id: topContentArea
                    height: parent.height

                    Delegates.LocalSettingDelegate {
                        id: mycroftIntegrationDelegate
                        implicitWidth: desktopThemeView.view.cellWidth * 2
                        implicitHeight: desktopThemeView.view.cellHeight
                        isChecked: kcm.mycroftIntegrationActive() ? 1 : 0
                        name: "Mycroft Integration"
                        customType: "mycroftIntegration"
                        KeyNavigation.up: kcmcloseButton
                        KeyNavigation.right: pmInhibitionDelegate
                        KeyNavigation.down: desktopThemeView
                        onActiveFocusChanged: {
                            if(activeFocus){
                                contentLayout.currentSection = topContentArea
                            }
                        }
                    }

                    Delegates.LocalSettingDelegate {
                        id: pmInhibitionDelegate
                        implicitWidth: desktopThemeView.view.cellWidth * 2
                        implicitHeight: desktopThemeView.view.cellHeight
                        isChecked: kcm.pmInhibitionActive() ? 1 : 0
                        name: "Power Inhibition"
                        customType: "pmInhibition"
                        KeyNavigation.up: kcmcloseButton
                        KeyNavigation.right: coloredTileDelegate
                        KeyNavigation.left: mycroftIntegrationDelegate
                        KeyNavigation.down: desktopThemeView
                        onActiveFocusChanged: {
                            if(activeFocus){
                                contentLayout.currentSection = topContentArea
                            }
                        }
                    }

                    Delegates.LocalSettingDelegate {
                        id: coloredTileDelegate
                        implicitWidth: desktopThemeView.view.cellWidth * 2
                        implicitHeight: desktopThemeView.view.cellHeight
                        isChecked: kcm.useColoredTiles() ? 1 : 0
                        name: "Colored Tiles"
                        customType: "coloredTile"
                        KeyNavigation.up: kcmcloseButton
                        KeyNavigation.left: pmInhibitionDelegate
                        KeyNavigation.right: expandableTileDelegate
                        KeyNavigation.down: desktopThemeView
                        onActiveFocusChanged: {
                            if(activeFocus){
                                contentLayout.currentSection = topContentArea
                            }
                        }
                    }

                    Delegates.LocalSettingDelegate {
                        id: expandableTileDelegate
                        implicitWidth: desktopThemeView.cellWidth * 2
                        implicitHeight: desktopThemeView.cellHeight
                        isChecked: kcm.useExpandingTiles() ? 1 : 0
                        name: "Expanding Tiles"
                        customType: "exapandableTile"
                        KeyNavigation.up: kcmcloseButton
                        KeyNavigation.left: coloredTileDelegate
                        KeyNavigation.right: timeDateSettingsDelegate
                        KeyNavigation.down: desktopThemeView
                        onActiveFocusChanged: {
                            if(activeFocus){
                                contentLayout.currentSection = topContentArea
                            }
                        }
                    }

                    Delegates.TimeDelegate {
                        id: timeDateSettingsDelegate
                        implicitWidth: desktopThemeView.cellWidth * 2
                        implicitHeight: desktopThemeView.cellHeight
                        name: "Adjust Date & Time"
                        KeyNavigation.up: kcmcloseButton
                        KeyNavigation.left: expandableTileDelegate
                        KeyNavigation.down: desktopThemeView
                        onActiveFocusChanged: {
                            if(activeFocus){
                                contentLayout.currentSection = topContentArea
                            }
                        }
                    }
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
                    title: "General Appearance"
                    navigationUp: mycroftIntegrationDelegate
                    navigationDown: kcmcloseButton
                    enabled: !deviceTimeSettingsArea.opened
                    delegate: Delegates.ThemeDelegate {
                        text: model.display
                    }

                    onActiveFocusChanged: {
                        if(activeFocus){
                            contentLayout.currentSection = desktopThemeView
                        }
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
