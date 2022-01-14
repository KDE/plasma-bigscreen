/*
    SPDX-FileCopyrightText: 2019 Aditya Mehra <aix.m@outlook.com>
    SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.14
import QtQuick.Layouts 1.14
import QtQuick.Controls 2.14 as Controls
import QtQuick.Window 2.14
import QtGraphicalEffects 1.14
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.kquickcontrolsaddons 2.0
import org.kde.kirigami 2.12 as Kirigami

import "launcher"
import "indicators" as Indicators
import org.kde.mycroft.bigscreen 1.0 as BigScreen

Item {
    id: root
    Layout.minimumWidth: Screen.desktopAvailableWidth
    Layout.minimumHeight: Screen.desktopAvailableHeight * 0.6

    property bool mycroftIntegration: plasmoid.nativeInterface.bigLauncherDbusAdapterInterface.mycroftIntegrationActive() ? 1 : 0

    property Item wallpaper

    Connections {
        target: plasmoid.nativeInterface.bigLauncherDbusAdapterInterface
        onEnableMycroftIntegrationChanged: {
            mycroftIntegration = plasmoid.nativeInterface.bigLauncherDbusAdapterInterface.mycroftIntegrationActive()
            if(mycroftIntegration) {
                mycroftIndicatorLoader.active = true
                mycroftWindowLoader.active = true
            } else {
                mycroftIndicatorLoader.item.disconnectclose()
                mycroftWindowLoader.item.disconnectclose()
            }
        }
        onEnablePmInhibitionChanged: {
            var powerInhibition = plasmoid.nativeInterface.bigLauncherDbusAdapterInterface.pmInhibitionActive()
            if(powerInhibition) {
                pmInhibitItem.inhibit = true
            } else {
                pmInhibitItem.inhibit = false
            }
        }
    }

    Containment.onAppletAdded: {
        addApplet(applet, x, y);
    }

    PowerManagementItem {
        id: pmInhibitItem
        //inhibit: plasmoid.nativeInterface.bigLauncherDbusAdapterInterface.pmInhibitionActive()
    }

    PlasmaCore.ColorScope.colorGroup: PlasmaCore.Theme.ComplementaryColorGroup
    Component.onCompleted: {
        for (var i in plasmoid.applets) {
            root.addApplet(plasmoid.applets[i], -1, -1)
        }
        console.log("checking for power inhibition")
        console.log(plasmoid.nativeInterface.bigLauncherDbusAdapterInterface.pmInhibitionActive())
        pmInhibitItem.inhibit = plasmoid.nativeInterface.bigLauncherDbusAdapterInterface.pmInhibitionActive()
    }

    function addApplet(applet, x, y) {
        var container = appletContainerComponent.createObject(appletsLayout)
        print("Applet added: " + applet + " " + applet.title)
        //container.width = units.iconSizes.medium
        container.height = appletsLayout.height

        applet.parent = container;
        container.applet = applet;
        applet.anchors.fill = container;
        applet.visible = true;
        applet.expanded = false;
    }

    Component {
        id: appletContainerComponent
        Item {
            property Item applet
            visible: applet && applet.status !== PlasmaCore.Types.HiddenStatus && applet.status !== PlasmaCore.Types.PassiveStatus
            Layout.fillHeight: true
            Layout.minimumWidth: Math.max(applet.implicitWidth, applet.Layout.preferredWidth, applet.Layout.minimumWidth) + units.gridUnit
            Layout.maximumWidth: Layout.minimumWidth
        }
    }

    FeedbackWindow {
        id: feedbackWindow
    }

    // Loader to make Mycroft completely optional
    Loader {
        id: mycroftWindowLoader
        source: mycroftIntegration && Qt.resolvedUrl("MycroftWindow.qml") ? Qt.resolvedUrl("MycroftWindow.qml") : null
    }

    ConfigWindow {
        id: plasmoidConfig
    }

    LinearGradient {
        anchors {
            top: parent.top
            bottom: parent.bottom
        }
        x: root.Window.active ? 0 : -width
        Behavior on x {
            XAnimator {
                duration: units.longDuration
                easing.type: Easing.InOutQuad
            }
        }
        width: parent.width/2
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
                color:  "transparent"
            }
        }
    }

    PlasmaCore.ColorScope {
        id: topBar
        anchors {
            left: parent.left
            right: parent.right
        }
        z: launcher.z + 1
        colorGroup: PlasmaCore.Theme.NormalColorGroup
        Kirigami.Theme.colorSet: Kirigami.Theme.Window
        height: units.iconSizes.medium + units.smallSpacing * 2
        opacity: root.Window.active

        y: root.Window.active ? 0 : -height
        Behavior on y {
            YAnimator {
                duration: units.longDuration
                easing.type: Easing.InOutQuad
            }
        }
        Behavior on opacity {
            OpacityAnimator {
                duration: units.longDuration
                easing.type: Easing.InOutQuad
            }
        }

        Rectangle {
            anchors.fill: parent
            color: PlasmaCore.ColorScope.backgroundColor
        }
        RowLayout {
            id: appletsLayout
            anchors {
                left: parent.left
                top: parent.top
                bottom: parent.bottom
                margins: units.smallSpacing
            }
        }

        RowLayout {
            anchors {
                right: parent.right
                top: parent.top
                bottom: parent.bottom
                margins: units.smallSpacing
            }

            // Loader to make Mycroft completely optional
            Loader {
                id: mycroftIndicatorLoader
                Layout.fillHeight: true
                source: mycroftIntegration && Qt.resolvedUrl("MycroftIndicator.qml") ? Qt.resolvedUrl("MycroftIndicator.qml") : null
            }

            Indicators.KdeConnect {
                id: kdeconnectIndicator
                Layout.fillHeight: true
                implicitWidth: height
                KeyNavigation.down: launcher
                KeyNavigation.right: volumeIndicator
                KeyNavigation.tab: volumeIndicator
                KeyNavigation.backtab: launcher
                KeyNavigation.left: kdeconnectIndicator
            }

            Indicators.Volume {
                id: volumeIndicator
                Layout.fillHeight: true
                implicitWidth: height
                KeyNavigation.down: launcher
                KeyNavigation.right: wifiIndicator
                KeyNavigation.tab: wifiIndicator
                KeyNavigation.backtab: launcher
                KeyNavigation.left: kdeconnectIndicator
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

        LinearGradient {
            property int radius: units.gridUnit
            implicitWidth: radius
            implicitHeight: radius
            anchors {
                left: parent.left
                right: parent.right
                top: parent.bottom
            }

            start: Qt.point(0, 0)
            end: Qt.point(0, height)
            gradient: Gradient {
                GradientStop {
                    position: 0.0
                    color: Qt.rgba(0, 0, 0, 0.25)
                }
                GradientStop {
                    position: 0.20
                    color: Qt.rgba(0, 0, 0, 0.1)
                }
                GradientStop {
                    position: 0.35
                    color: Qt.rgba(0, 0, 0, 0.02)
                }
                GradientStop {
                    position: 1.0
                    color:  "transparent"
                }
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
                        duration: units.longDuration
                        easing.type: Easing.InOutQuad
                    }
                    YAnimator {
                        duration: units.longDuration
                        easing.type: Easing.InOutQuad
                    }
                }
            }
        ]
    }
}
