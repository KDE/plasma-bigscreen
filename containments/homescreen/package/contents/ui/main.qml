/*
    SPDX-FileCopyrightText: 2019 Aditya Mehra <aix.m@outlook.com>
    SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15 as Controls
import QtQuick.Window 2.15
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.kquickcontrolsaddons 2.0
import org.kde.kirigami 2.19 as Kirigami

import "launcher"
import "indicators" as Indicators
import org.kde.bigscreen 1.0 as BigScreen
import Qt5Compat.GraphicalEffects
import org.kde.coreaddons 1.0 as KCoreAddons
import org.kde.kirigamiaddons.components 1.0 as KirigamiComponents

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

    function listProperty(item) {
        console.log("Listing properties for " + item)
        for (var p in item)
            console.log(p + ": " + item[p]);
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
        console.log("checking for power inhibition")
        console.log(Plasmoid.bigLauncherDbusAdapterInterface.pmInhibitionActive())
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
                radius: Kirigami.Units.gridUnit / 2
                anchors.fill: parent
                opacity: 0.3
                clip: true
            }

            Kirigami.ShadowedRectangle {
                anchors.fill: parent
                color: Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 0.9)
                radius: Kirigami.Units.gridUnit / 2
                shadow {
                    size: Kirigami.Units.largeSpacing * 2
                }
            }
        }

        z: launcher.z + 1
        height: Kirigami.Units.gridUnit * 4
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
            height: parent.height - Kirigami.Units.smallSpacing * 2

            anchors {
                verticalCenter: parent.verticalCenter
                right: indicatorsPanelArea.left
                rightMargin: Kirigami.Units.smallSpacing
            }

            Item {
                anchors.fill: parent
                anchors.margins: Kirigami.Units.largeSpacing

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
                    KeyNavigation.down: launcher
                    KeyNavigation.right: volumeIndicator
                }

                Indicators.Volume {
                    id: volumeIndicator
                    Layout.fillHeight: true
                    implicitWidth: height
                    KeyNavigation.down: launcher
                    KeyNavigation.right: wifiIndicator
                    KeyNavigation.tab: wifiIndicator
                    KeyNavigation.backtab: launcher
                }

                Indicators.Wifi {
                    id: wifiIndicator
                    Layout.fillHeight: true
                    implicitWidth: height
                    KeyNavigation.down: launcher
                    KeyNavigation.right: shutdownIndicator
                    KeyNavigation.tab: shutdownIndicator
                    KeyNavigation.backtab: volumeIndicator
                    KeyNavigation.left: volumeIndicator
                }
                Indicators.Shutdown {
                    id: shutdownIndicator
                    KeyNavigation.down: launcher
                    KeyNavigation.right: launcher
                    KeyNavigation.tab: launcher
                    KeyNavigation.backtab: wifiIndicator
                    KeyNavigation.left: wifiIndicator
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
                rightMargin: Kirigami.Units.largeSpacing
            }

            KirigamiComponents.AvatarButton {
                width: Kirigami.Units.iconSizes.large
                height: Kirigami.Units.iconSizes.large
                source: kuser.faceIconUrl + "?timestamp=" + Date.now()
                name: kuser.fullName
                anchors.centerIn: parent
            }
        }
    }
}
