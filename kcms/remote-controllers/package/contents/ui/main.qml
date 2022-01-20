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
import org.kde.kcm 1.1 as KCM
import org.kde.mycroft.bigscreen 1.0 as BigScreen
import "delegates" as Delegates

KCM.SimpleKCM {
    id: root

    title: i18n("Remote Controllers")
    background: null
    leftPadding: Kirigami.Units.smallSpacing
    topPadding: 0
    rightPadding: Kirigami.Units.smallSpacing
    bottomPadding: 0

    Component.onCompleted: {
        connectionView.forceActiveFocus();
    }

    ListModel {
        id: supportedControllers
        ListElement { display: "HDMI-CEC"; iconName: "input-dialpad"; toolTip: "TV Remote Controller"}
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
                text: "Remote Controllers"
            }
        }

        Item {
            id: footerMain
            anchors.left: parent.left
            anchors.right: deviceSetupView.left
            anchors.leftMargin: -Kirigami.Units.largeSpacing
            anchors.bottom: parent.bottom
            implicitHeight: Kirigami.Units.gridUnit * 2

            Button {
                id: kcmcloseButton
                implicitHeight: Kirigami.Units.gridUnit * 2
                width: supportedControllers.count > 0 ? parent.width : (root.width + Kirigami.Units.largeSpacing)

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

                Keys.onUpPressed: connectionView.forceActiveFocus()

                onClicked: {
                    Window.window.close()
                }

                Keys.onReturnPressed: {
                    Window.window.close()
                }
            }
        }

        Item {
            clip: true
            anchors.left: parent.left
            anchors.top: headerAreaTop.bottom
            anchors.bottom: footerMain.top
            width: parent.width - deviceSetupView.width

            ColumnLayout {
                anchors.fill: parent
                anchors.leftMargin: Kirigami.Units.largeSpacing
                anchors.topMargin: Kirigami.Units.largeSpacing * 2

                BigScreen.TileView {
                    id: connectionView
                    focus: true
                    model:  supportedControllers
                    Layout.alignment: Qt.AlignTop
                    title: supportedControllers.count > 0 ? "Found Devices" : "No Devices Found"
                    currentIndex: 0
                    delegate: Delegates.DeviceDelegate{}
                    navigationDown: kcmcloseButton
                    Behavior on x {
                        NumberAnimation {
                            duration: Kirigami.Units.longDuration * 2
                            easing.type: Easing.InOutQuad
                        }
                    }
                    onCurrentItemChanged: {
                        deviceSetupView.currentDevice = currentItem.deviceObj
                    }
                }
            }
        }

        DeviceSetupView {
            id: deviceSetupView
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            visible: supportedControllers.count > 0 ? 1 : 0
            anchors.rightMargin: -Kirigami.Units.smallSpacing
            width: Kirigami.Units.gridUnit * 15
        }

        Popup {
            id: keySetupPopUp
            x: ((parent.width - deviceSetupView.width) - width)  / 2
            y: (parent.height - height) / 2
            width: parent.width * 0.70
            height: parent.height * 0.10
            property var keyType

            function keyCodeRecieved(keyCode) {
                kcm.setCecKeyConfig(keyType[1], keyCode)
                keySetupPopUp.close()
            }

            onOpened: {
                var getCecKey = kcm.getCecKeyFromRemotePress()
                keyCodeRecieved(getCecKey)
            }

            contentItem: Item {
                anchors.fill: parent

                PlasmaComponents.Label {
                    anchors.centerIn: parent
                    text: "Select Key On Your TV Remote For " + keySetupPopUp.keyType[0]
                }
            }
        }
    }
}
