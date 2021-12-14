/*
    SPDX-FileCopyrightText: 2018 Aditya Mehra <aix.m@outlook.com>

    SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL

*/

import QtQuick.Layouts 1.14
import QtQuick 2.14
import QtQuick.Window 2.14
import QtQuick.Controls 2.14
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.kirigami 2.12 as Kirigami
import org.kde.plasma.networkmanagement 0.2 as PlasmaNM
import org.kde.kcm 1.1 as KCM
import org.kde.mycroft.bigscreen 1.0 as BigScreen
import "views" as Views
import "delegates" as Delegates

KCM.SimpleKCM {
    id: networkSelectionView
    
    title: Screen.devicePixelRatio.toFixed(2) //i18n("Network")
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
                text: "Networks"
            }
        }

        Item {
            id: footerMain
            anchors.left: parent.left
            anchors.right: deviceConnectionView.left
            anchors.leftMargin: -Kirigami.Units.largeSpacing
            anchors.bottom: parent.bottom
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
                            Layout.preferredWidth: PlasmaCore.Units.iconSizes.small
                            Layout.preferredHeight: PlasmaCore.Units.iconSizes.small
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
    }

        ColumnLayout {
            anchors.left: parent.left
            anchors.leftMargin: Kirigami.Units.largeSpacing
            anchors.top: headerAreaTop.bottom
            anchors.topMargin: Kirigami.Units.largeSpacing * 2
            anchors.bottom: footerMain.top
            width: parent.width - deviceConnectionView.width

            BigScreen.TileView {
                id: connectionView
                focus: true
                model: appletProxyModel
                Layout.alignment: Qt.AlignTop
                title: i18n("Manage Connections")
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
                    deviceConnectionViewDetails.currentIndex = connectionView.currentIndex
                    deviceConnectionViewDetails.positionViewAtIndex(currentIndex, ListView.Center);
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
        
        Rectangle {
            id: deviceConnectionView
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.rightMargin: -Kirigami.Units.smallSpacing
            height: parent.height
            width: Kirigami.Units.gridUnit * 15
            color: Kirigami.Theme.backgroundColor

            ListView {
                id: deviceConnectionViewDetails
                model: connectionView.model
                anchors.fill: parent
                anchors.topMargin: parent.height * 0.075
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
}
