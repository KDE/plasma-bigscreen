/*
    SPDX-FileCopyrightText: 2019 Aditya Mehra <aix.m@outlook.com>
    SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import QtQuick.Window
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kquickcontrolsaddons
import org.kde.kirigami as Kirigami
import org.kde.bigscreen as BigScreen
import Qt5Compat.GraphicalEffects
import org.kde.coreaddons as KCoreAddons
import org.kde.kirigamiaddons.components as KirigamiComponents
import "launcher"
import "indicators" as Indicators

ContainmentItem {
    id: root
    Layout.minimumWidth: Screen.desktopAvailableWidth
    Layout.minimumHeight: Screen.desktopAvailableHeight * 0.6

    property Item wallpaper

    PlasmaCore.Action {
        id: configureAction
        onTriggered: Plasmoid
    }

    function configureWallpaper() {
        Plasmoid.internalAction("configure").trigger();
    }

    Connections {
        target: Plasmoid.bigLauncherDbusAdapterInterface

        function onEnablePmInhibitionChanged(pmInhibition) {
            var powerInhibition = Plasmoid.bigLauncherDbusAdapterInterface.pmInhibitionActive()
            if (powerInhibition) {
                pmInhibitItem.inhibit = true
            } else {
                pmInhibitItem.inhibit = false
            }
        }
    }

    Containment.onAppletAdded: (applet, x, y) => {
        addApplet(applet, x, y);
    }

    PowerManagementItem {
        id: pmInhibitItem
    }

    Component.onCompleted: {
        for (var i in plasmoid.applets) {
            root.addApplet(plasmoid.applets[i], -1, -1)
        }
        pmInhibitItem.inhibit = Plasmoid.bigLauncherDbusAdapterInterface.pmInhibitionActive()
    }

    function addApplet(applet, x, y) {
        var container = appletContainerComponent.createObject(appletsLayout)
        print("Applet added: " + applet + " " + applet.title)

        const appletItem = root.itemFor(applet);
        appletItem.parent = container;
        container.applet = appletItem;
        appletItem.anchors.fill = container;
        appletItem.visible = true;
        appletItem.expanded = false;
    }

    Component {
        id: appletContainerComponent
        Item {
            property Item applet
            visible: applet && applet.status !== PlasmaCore.Types.HiddenStatus && applet.status !== PlasmaCore.Types.PassiveStatus
            Layout.fillHeight: true
            Layout.fillWidth: true 
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        }
    }

    FeedbackWindow {
        id: feedbackWindow
    }

    ConfigWindow {
        id: configWindow
    }

    TaskWindowView {
        id: taskWindowView
    }

    FavoritesManager {
        id: favsManagerWindowView
    }

    LinearGradient {
        anchors {
            top: parent.top
            bottom: parent.bottom
        }
        x: root.Window.active ? 0 : -width
        Behavior on x {
            XAnimator {
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InOutQuad
            }
        }
        width: parent.width / 2
        start: Qt.point(0, 0)
        end: Qt.point(width, 0)
        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: Qt.rgba(0, 0, 0, 0.75)
            }
            GradientStop {
                position: 0.5
                color: Qt.rgba(0, 0, 0, 0.5)
            }
            GradientStop {
                position: 1.0
                color: "transparent"
            }
        }
    }

    LauncherMenu {
        id: launcher
        width: parent.width
        height: parent.height - topBar.height

        states: [
            State {
                when: root.Window.activeFocusItem !== null
                PropertyChanges {
                    target: launcher
                    opacity: 1
                    y: topBar.height
                }
                StateChangeScript {
                    script: {
                        launcher.activateAppView()
                    }
                }
            },
            State {
                when: root.Window.activeFocusItem === null
                PropertyChanges {
                    target: launcher
                    opacity: 0
                    y: root.height / 4
                }
            }
        ]

        transitions: [
            Transition {
                ParallelAnimation {
                    OpacityAnimator {
                        duration: Kirigami.Units.longDuration
                        easing.type: Easing.InOutQuad
                    }
                    YAnimator {
                        duration: Kirigami.Units.longDuration
                        easing.type: Easing.InOutQuad
                    }
                }
            }
        ]
    }

    KCoreAddons.KUser {
        id: kuser
    }

    Indicators.AbstractIndicatorArea {
        id: topBarFavsIndicatorArea
        anchors.left: parent.left
        anchors.leftMargin: Kirigami.Units.largeSpacing
        anchors.verticalCenter: topBar.verticalCenter
        width: favsIndicator.activeFocus ? Kirigami.Units.gridUnit * 9 : Kirigami.Units.gridUnit * 5
        z: launcher.z + 1
        opacity: root.Window.active
        y: root.Window.active ? 0 : -height

        Indicators.Favorites {
            id: favsIndicator
            anchors.fill: parent
            anchors.margins: Kirigami.Units.smallSpacing
            KeyNavigation.down: launcher
            KeyNavigation.right: tasksIndicator.visible ? tasksIndicator : settingsIndicator
            KeyNavigation.tab: tasksIndicator.visible ? tasksIndicator : settingsIndicator
        }
    }

    Indicators.AbstractIndicatorArea {
        id: topBarTaskIndicatorArea
        anchors.right: topBar.left
        anchors.rightMargin: Kirigami.Units.largeSpacing
        anchors.verticalCenter: topBar.verticalCenter
        z: launcher.z + 1
        opacity: root.Window.active
        y: root.Window.active ? 0 : -height
        visible: taskWindowView.modelCount > 0

        Indicators.Tasks {
            id: tasksIndicator
            anchors.fill: parent
            anchors.margins: Kirigami.Units.smallSpacing
            visible: taskWindowView.modelCount > 0
            KeyNavigation.down: launcher
            KeyNavigation.left: favsIndicator
            KeyNavigation.right: settingsIndicator
            KeyNavigation.tab: settingsIndicator
        }
    }

    Controls.Control {
        id: topBar

        width: Kirigami.Units.gridUnit * 28

        anchors {
            right: parent.right
        }

        background: Item {
            anchors.fill: parent
            anchors.margins: Kirigami.Units.largeSpacing

            Rectangle {
                id: bgSourceItem
                radius: 6
                anchors.fill: parent
                opacity: 0.3
                clip: true
            }

            Kirigami.ShadowedRectangle {
                anchors.fill: parent
                color: Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 0.9)
                radius: 6
                shadow {
                    size: Kirigami.Units.largeSpacing * 1
                }
            }
        }

        z: launcher.z + 1
        height: Kirigami.Units.gridUnit * 5
        opacity: root.Window.active
        y: root.Window.active ? 0 : -height

        Behavior on y {
            YAnimator {
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InOutQuad
            }
        }
        Behavior on opacity {
            OpacityAnimator {
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InOutQuad
            }
        }

        Item {
            id: appletsPanelArea
            width: Kirigami.Units.gridUnit * 10
            height: parent.height

            anchors {
                verticalCenter: parent.verticalCenter
                left: parent.left
                right: indicatorsPanelArea.left
            }

            Item {
                anchors.fill: parent
                anchors.margins: Kirigami.Units.largeSpacing * 2

                RowLayout {
                    id: appletsLayout
                    anchors.centerIn: parent 
                    width: parent.width 
                    height: parent.height 
                    spacing: Kirigami.Units.smallSpacing
                }
            }
        }

        Rectangle {
            id: indicatorsPanelArea
            width: indicatorsPanel.implicitWidth + Kirigami.Units.largeSpacing * 2
            radius: Kirigami.Units.gridUnit / 2
            height: Kirigami.Units.iconSizes.large + Kirigami.Units.smallSpacing * 2
            color: Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 0.3)

            anchors {
                verticalCenter: parent.verticalCenter
                right: profilePanelArea.left
                rightMargin: Kirigami.Units.largeSpacing * 2
            }

            RowLayout {
                id: indicatorsPanel
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.margins: Kirigami.Units.smallSpacing

                Indicators.Settings {
                    id: settingsIndicator
                    Layout.fillHeight: true
                    implicitWidth: height
                    KeyNavigation.left: taskWindowView.modelCount > 0 ? tasksIndicator : null
                    KeyNavigation.down: launcher
                    KeyNavigation.right: volumeIndicator
                    KeyNavigation.tab: volumeIndicator
                    KeyNavigation.backtab: taskWindowView.modelCount > 0 ? tasksIndicator : null
                }

                Indicators.Volume {
                    id: volumeIndicator
                    Layout.fillHeight: true
                    implicitWidth: height
                    KeyNavigation.down: launcher
                    KeyNavigation.right: wifiIndicator
                    KeyNavigation.tab: wifiIndicator
                    KeyNavigation.backtab: settingsIndicator
                    KeyNavigation.left: settingsIndicator
                }

                Indicators.Wifi {
                    id: wifiIndicator
                    Layout.fillHeight: true
                    implicitWidth: height
                    KeyNavigation.down: launcher
                    KeyNavigation.right: kdeConnectIndicator
                    KeyNavigation.tab: kdeConnectIndicator
                    KeyNavigation.backtab: volumeIndicator
                    KeyNavigation.left: volumeIndicator
                }

                Indicators.KdeConnect {
                    id: kdeConnectIndicator
                    Layout.fillHeight: true
                    implicitWidth: height
                    KeyNavigation.down: launcher
                    KeyNavigation.right: shutdownIndicator
                    KeyNavigation.tab: shutdownIndicator
                    KeyNavigation.backtab: wifiIndicator
                    KeyNavigation.left: wifiIndicator
                }

                Indicators.Shutdown {
                    id: shutdownIndicator
                    KeyNavigation.down: launcher
                    KeyNavigation.right: launcher
                    KeyNavigation.tab: launcher
                    KeyNavigation.backtab: kdeConnectIndicator
                    KeyNavigation.left: kdeConnectIndicator
                }
            }
        }

        Item {
            id: profilePanelArea
            width: Kirigami.Units.iconSizes.large + Kirigami.Units.smallSpacing * 2
            height: parent.height - Kirigami.Units.smallSpacing * 2

            anchors {
                verticalCenter: parent.verticalCenter
                right: parent.right
                rightMargin: Kirigami.Units.largeSpacing * 2
            }

            KirigamiComponents.AvatarButton {
                width: Kirigami.Units.iconSizes.large
                height: Kirigami.Units.iconSizes.large
                source: kuser.faceIconUrl + "?timestamp=" + Date.now()
                name: kuser.fullName
                anchors.centerIn: parent

                onClicked: {
                    BigScreen.Global.promptLogoutGreeter("promptAll")
                }

                Keys.onReturnPressed: onClicked()
            }
        }
    }
}
