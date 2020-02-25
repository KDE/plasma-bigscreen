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
import QtGraphicalEffects 1.12
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.kquickcontrolsaddons 2.0
import org.kde.kirigami 2.5 as Kirigami
import Mycroft 1.0 as Mycroft

import "launcher"
import "indicators" as Indicators
import org.kde.mycroft.bigscreen 1.0 as BigScreen

Item {
    id: root
    Layout.minimumWidth: Screen.desktopAvailableWidth
    Layout.minimumHeight: Screen.desktopAvailableHeight * 0.6

    property Item wallpaper
    Controls.CheckBox {
        z: 999
        anchors {
            top: topBar.bottom
            right: parent.right
        }
        text: "Use Colored Tiles"
        checked: BigScreen.Hack.coloredTiles
        onCheckedChanged: BigScreen.Hack.coloredTiles = checked
    }

    Containment.onAppletAdded: {
        addApplet(applet, x, y);
    }

    PlasmaCore.ColorScope.colorGroup: Plasmacore.Theme.ComplementaryColorGroup
    Component.onCompleted: {
        for (var i in plasmoid.applets) {
            root.addApplet(plasmoid.applets[i], -1, -1)
        }

        Mycroft.MycroftController.start();
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

    MycroftWindow {
        id: mycroftWindow
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

            Kirigami.Heading {
                id: inputQuery
                Kirigami.Theme.colorSet: mainView.Kirigami.Theme.colorSet
                level: 3
                opacity: 0
                onTextChanged: {
                    opacity = 1;
                    utteranceTimer.restart();
                }
                Timer {
                    id: utteranceTimer
                    interval: 8000
                    onTriggered: {
                        inputQuery.text = "";
                        inputQuery.opacity = 0
                    }
                }
                Behavior on opacity {
                    OpacityAnimator {
                        duration: Kirigami.Units.longDuration
                        easing.type: Easing.InOutQuad
                    }
                }

                Connections {
                    target: Mycroft.MycroftController
                    onIntentRecevied: {
                        if(type == "recognizer_loop:utterance") {
                            inputQuery.text = data.utterances[0]
                        }
                    }
                    onServerReadyChanged: {
                        if (Mycroft.MycroftController.serverReady) {
                            inputQuery.text = "";
                        } else {
                            inputQuery.text = i18n("Not Ready");
                            utteranceTimer.running = false;
                        }
                    }
                    onStatusChanged: {
                        switch (Mycroft.MycroftController.status) {
                        case Mycroft.MycroftController.Connecting:
                        case Mycroft.MycroftController.Error:
                        case Mycroft.MycroftController.Stopped:
                            inputQuery.text = i18n("Not Ready");
                            utteranceTimer.running = false;
                            break;
                        default:
                            if (Mycroft.MycroftController.serverReady) {
                                inputQuery.text = "";
                            }
                            break;
                        }

                    }
                }
            }
            Mycroft.StatusIndicator {
                id: si
                z: 2
                visible: !mycroftWindow.visible
                Layout.preferredWidth: height
                Layout.fillHeight: true
            }
            Indicators.Volume {
                id: volumeIndicator
                Layout.fillHeight: true
                implicitWidth: height
                KeyNavigation.down: launcher
                KeyNavigation.right: wifiIndicator
                KeyNavigation.tab: wifiIndicator
                KeyNavigation.backtab: launcher
                KeyNavigation.left: volumeIndicator
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
                when: root.Window.active
                PropertyChanges {
                    target: launcher
                    opacity: 1
                    y: topBar.height
                }
            },
            State {
                when: !root.Window.active
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
