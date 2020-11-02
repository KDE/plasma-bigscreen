/*
 * Copyright 2018 by Aditya Mehra <aix.m@outlook.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

import QtQuick.Layouts 1.4
import QtQuick 2.12
import QtQuick.Window 2.3
import QtQuick.Controls 2.3
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.kirigami 2.8 as Kirigami
import org.kde.plasma.networkmanagement 0.2 as PlasmaNM
import org.kde.kcm 1.1 as KCM
import org.kde.mycroft.bigscreen 1.0 as BigScreen
import "views" as Views
import "delegates" as Delegates

KCM.SimpleKCM {
    id: networkSelectionView
    
    title: i18n("Network")
    background: null
    
    leftPadding: Kirigami.Units.smallSpacing
    topPadding: 0
    rightPadding: Kirigami.Units.smallSpacing
    bottomPadding: 0
    
    property string pathToRemove
    property string nameToRemove
    property bool isStartUp: false
    property var securityType
    property var connectionName
    property var devicePath
    property var specificPath

    function connectToOpenNetwork(){
        handler.addAndActivateConnection(devicePath, specificPath, passField.text)
    }
    
    onActiveFocusChanged: {
        if (activeFocus) {
            handler.requestScan();
            connectionView.forceActiveFocus();
        }
    }

    function removeConnection() {
        handler.removeConnection(pathToRemove)
    }
    
    PlasmaNM.EnabledConnections {
        id: enabledConnections
    }

    PlasmaNM.NetworkStatus {
        id: networkStatus
    }

    PlasmaNM.ConnectionIcon {
        id: connectionIconProvider
    }

    PlasmaNM.Handler {
        id: handler
    }

    PlasmaNM.AvailableDevices {
        id: availableDevices
    }

    PlasmaNM.NetworkModel {
        id: connectionModel
    }

    Component {
        id: networkModelComponent
        PlasmaNM.NetworkModel {}
    }

    PlasmaNM.AppletProxyModel {
        id: appletProxyModel
        sourceModel: connectionModel
    }
    
    PlasmaNM.AppletProxyModel {
        id: connectedProxyModel
        sourceModel: connectionModel
    }

    onRefreshingChanged: {
        if (refreshing) {
            refreshTimer.restart()
            handler.requestScan();
        }
    }
    Timer {
        id: refreshTimer
        interval: 3000
        onTriggered: networkSelectionView.refreshing = false
    }

    footer: Item {
        implicitHeight: Kirigami.Units.gridUnit * 2

        RowLayout {
            id: footerArea
            anchors.fill: parent

            Button {
                id: reloadButton
                Layout.fillWidth: true
                Layout.fillHeight: true
                KeyNavigation.up: connectionView
                KeyNavigation.right: kcmcloseButton

                background: Rectangle {
                    color: reloadButton.activeFocus ? Kirigami.Theme.highlightColor : Kirigami.Theme.backgroundColor
                }

                contentItem: Item {
                    RowLayout {
                        anchors.centerIn: parent
                        Kirigami.Icon {
                            Layout.preferredWidth: Kirigami.Units.iconSizes.small
                            Layout.preferredHeight: Kirigami.Units.iconSizes.small
                            source: "view-refresh"
                        }
                        Label {
                            text: i18n("Refresh")
                        }
                    }
                }

                onClicked: {
                    networkSelectionView.refreshing = true;
                    connectionView.contentY = -Kirigami.Units.gridUnit * 4;
                }
                Keys.onReturnPressed: {
                    networkSelectionView.refreshing = true;
                    connectionView.contentY = -Kirigami.Units.gridUnit * 4;
                }
            }
            
            Button {
                id: kcmcloseButton
                KeyNavigation.up: connectionView
                KeyNavigation.left: reloadButton
                Layout.fillWidth: true
                Layout.fillHeight: true

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
    }

    Dialog {
        id: passwordLayer
        parent: networkSelectionView
        
        closePolicy: Popup.CloseOnEscape
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        dim: true
        onVisibleChanged: {
            if (visible) {
                passField.forceActiveFocus();
            } else {
                connectionView.forceActiveFocus();
            }
        }
        contentItem: ColumnLayout {
            implicitWidth: Kirigami.Units.gridUnit * 25

            Keys.onEscapePressed: passwordLayer.close()
            Kirigami.Heading {
                level: 2
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                text: i18n("Enter Password For %1", connectionName)
            }

            Kirigami.PasswordField {
                id: passField

                KeyNavigation.down: connectButton
                KeyNavigation.up: closeButton
                Layout.fillWidth: true
                placeholderText: i18n("Password...")
                validator: RegExpValidator {
                    regExp: if (securityType == PlasmaNM.Enums.StaticWep) {
                                /^(?:.{5}|[0-9a-fA-F]{10}|.{13}|[0-9a-fA-F]{26}){1}$/
                            } else {
                                /^(?:.{8,64}){1}$/
                            }
                }

                onAccepted: {
                    handler.addAndActivateConnection(devicePath, specificPath, passField.text)
                    passwordLayer.close();
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Button {
                    id: connectButton
                    KeyNavigation.up: passField
                    KeyNavigation.down: passField
                    KeyNavigation.left: passField
                    KeyNavigation.right: closeButton
                    Layout.fillWidth: true
                    text: i18n("Connect")

                    onClicked: passField.accepted();
                    Keys.onReturnPressed: {
                        passField.accepted();
                    }
                }
                
                Button {
                    id: closeButton
                    KeyNavigation.up: passField
                    KeyNavigation.down: passField
                    KeyNavigation.left: connectButton
                    KeyNavigation.right: passField
                    Layout.fillWidth: true
                    text: i18n("Cancel")

                    onClicked: passwordLayer.close();
                    Keys.onReturnPressed: {
                        passwordLayer.close();
                    }
                }
            }
            Item {
                Layout.fillHeight: true
            }
        }
    }

    Kirigami.OverlaySheet {
        id: networkActions
        parent: networkSelectionView
        showCloseButton: false

        onSheetOpenChanged: {
            if (sheetOpen) {
                forgetBtn.forceActiveFocus()
            }
        }

        contentItem: ColumnLayout {
            implicitWidth: Kirigami.Units.gridUnit * 25

            Label {
                Layout.fillWidth: true
                Layout.fillHeight: true
                wrapMode: Text.WordWrap
                text: i18n("Are you sure you want to forget the network %1?", nameToRemove)
            }
            
            RowLayout {
                Button {
                    id: forgetBtn
                    Layout.fillWidth: true
                    text: i18n("Forget")
                    
                    onClicked: {
                        removeConnection()
                        networkActions.close()
                        connectionView.forceActiveFocus()
                    }
                    
                    KeyNavigation.right: cancelBtn
                    
                    Keys.onReturnPressed: {
                        removeConnection()
                        networkActions.close()
                        connectionView.forceActiveFocus()
                    }
                    
                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: -Kirigami.Units.smallSpacing * 0.5
                        color: Kirigami.Theme.linkColor
                        visible: forgetBtn.focus ? 1 : 0
                        z: -10
                    }
                }
                Button {
                    id: cancelBtn
                    Layout.fillWidth: true
                    text: i18n("Cancel")
                    
                    KeyNavigation.left: forgetBtn

                    onClicked: {
                        networkActions.close()
                        connectionView.forceActiveFocus()
                    }
                    
                    Keys.onReturnPressed: {
                        networkActions.close()
                        connectionView.forceActiveFocus()
                    }
                    
                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: -Kirigami.Units.smallSpacing * 0.5
                        color: Kirigami.Theme.linkColor
                        visible: cancelBtn.focus ? 1 : 0
                        z: -10
                    }
                }
            }
        }
    }
    
    
    contentItem: FocusScope {
        ColumnLayout {
            anchors.left: parent.left
            anchors.leftMargin: Kirigami.Units.largeSpacing
            anchors.top: parent.top
            anchors.topMargin: Kirigami.Units.largeSpacing
            width: parent.width - deviceConnectionView.width
            height: parent.height

            BigScreen.TileView {
                id: connectionView
                focus: true
                model: appletProxyModel
                Layout.alignment: Qt.AlignTop
                title: i18n("Connections")
                currentIndex: 0
                delegate: Delegates.NetworkDelegate{}
                navigationDown: reloadButton
                Behavior on x {
                    NumberAnimation {
                        duration: Kirigami.Units.longDuration * 2
                        easing.type: Easing.InOutQuad
                    }
                }
                
                onCurrentItemChanged: {
                    deviceConnectionView.currentIndex = connectionView.currentIndex
                    deviceConnectionView.positionViewAtIndex(currentIndex, ListView.Center);
                }
            }
        }
        
        Kirigami.Separator {
            id: viewSept
            anchors.right: deviceConnectionView.left
            anchors.top: deviceConnectionView.top
            anchors.bottom: deviceConnectionView.bottom
            width: 1
        }
        
        ListView {
            id: deviceConnectionView
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.rightMargin: -Kirigami.Units.smallSpacing
            height: parent.height
            model: connectionView.model
            width: parent.width / 3.5
            layoutDirection: Qt.LeftToRight
            orientation: ListView.Horizontal
            snapMode: ListView.SnapOneItem;
            highlightRangeMode: ListView.StrictlyEnforceRange
            highlightFollowsCurrentItem: true
            spacing: Kirigami.Units.largeSpacing
            clip: true
            interactive: false
            implicitHeight: deviceConnectionView.implicitHeight
            currentIndex: 0
            delegate: DeviceConnectionItem{}
        }
    }
}
