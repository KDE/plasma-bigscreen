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
import QtQuick.Window 2.3
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.kquickcontrolsaddons 2.0
import org.kde.private.biglauncher 1.0 as Launcher
import org.kde.kirigami 2.5 as Kirigami

PlasmaCore.ColorScope {
    id: root
    Layout.minimumWidth: Screen.desktopAvailableWidth
    Layout.minimumHeight: Screen.desktopAvailableHeight * 0.6
    Plasmoid.backgroundHints: "NoBackground"

    readonly property int reservedSpaceForLabel: metrics.height
    property var appsModel: applicationListModel
    property var voiceAppsModel: voiceAppListModel
    signal activateAppView
    signal activateTopNavBar
    signal activateSettingsView

    MycroftWindow {}

    Launcher.ApplicationListModel {
        id: applicationListModel
    }

    Launcher.VoiceAppListModel {
        id: voiceAppListModel
    }
    
    Component.onCompleted: {
        root.forceActiveFocus();
        applicationListModel.loadApplications();
        voiceAppListModel.loadApplications();
        root.activateAppView();
    }

    Connections {
        target: applicationListModel
        onAppOrderChanged: {
            root.activateAppView()
        }
    }
    
    Connections {
        target: root
        onActivateTopNavBar: {
            topButtonBar.focus = true
        }
    }

    Controls.Label {
        id: metrics
        text: "M\nM"
        visible: false
    }

    ColumnLayout {
        anchors.fill: parent

        RowLayout {
            id: topButtonBar
            Layout.fillWidth: true
            Layout.preferredHeight: Kirigami.Units.iconSizes.medium
            
            PlasmaComponents3.Button {
                text: "Home"
                Layout.fillWidth: true
                focus: false
                Layout.preferredHeight: Kirigami.Units.iconSizes.medium
                flat: topBarLoader.currentIndex !== 0 ? 1 : 0
                onClicked: {
                    topBarLoader.currentIndex = 0
                    root.activateAppView()
                }
                
                Rectangle {
                    id: homeBtnHighLighter
                    visible: topButtonBar.focus && topBarLoader.currentIndex == 0 ? 1 : 0
                    color: Kirigami.Theme.linkColor
                    height: Kirigami.Units.smallSpacing * 0.5
                    anchors.left: parent.left
                    anchors.leftMargin: Kirigami.Units.smallSpacing
                    anchors.right: parent.right
                    anchors.rightMargin: Kirigami.Units.smallSpacing
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: Kirigami.Units.smallSpacing
                }
            }

            PlasmaComponents3.Button {
                text: "Settings"
                Layout.fillWidth: true
                Layout.preferredHeight: Kirigami.Units.iconSizes.medium
                focus: false
                flat: topBarLoader.currentIndex !== 1 ? 1 : 0
                onClicked: {
                    topBarLoader.currentIndex = 1
                }
                
                Rectangle {
                    id: settingsBtnHighLighter
                    visible: topButtonBar.focus && topBarLoader.currentIndex == 1 ? 1 : 0
                    color: Kirigami.Theme.linkColor
                    height: Kirigami.Units.smallSpacing * 0.5
                    anchors.left: parent.left
                    anchors.leftMargin: Kirigami.Units.smallSpacing
                    anchors.right: parent.right
                    anchors.rightMargin: Kirigami.Units.smallSpacing
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: Kirigami.Units.smallSpacing
                }
            }
            
            Keys.onRightPressed: {
                topBarLoader.currentIndex = 1
            }
            
            Keys.onLeftPressed: {
                topBarLoader.currentIndex = 0
            }
            
            Keys.onDownPressed: {
                if(topBarLoader.currentIndex == 0) {
                    root.activateAppView();
                } else if (topBarLoader.currentIndex == 1) {
                    root.activateSettingsView();
                }
            }
        }

        StackLayout {
            id: topBarLoader
            Layout.fillWidth: true
            Layout.preferredHeight: parent.height - (topButtonBar.height + Kirigami.Units.largeSpacing)
            currentIndex: 0
            clip: true

            Item {
                LauncherHome{}
            }

            Item {
                PlaceHolderPage{}
            }

            Component.onCompleted: {
                root.activateAppView();
            }
        }
    }
}
