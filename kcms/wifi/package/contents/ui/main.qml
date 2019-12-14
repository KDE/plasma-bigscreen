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
import QtQuick.Controls 2.3
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.kirigami 2.8 as Kirigami
import org.kde.plasma.networkmanagement 0.2 as PlasmaNM
import org.kde.kcm 1.1 as KCM

import org.kde.mycroft.bigscreen 1.0 as BigScreen

KCM.SimpleKCM {
    id: networkSelectionView

    title: i18n("Network")

    property string pathToRemove
    property string nameToRemove
    property bool isStartUp: false
    property var securityType
    property var connectionName
    property var devicePath
    property var specificPath


    onActiveFocusChanged: {
       if (activeFocus) {
           connectionView.forceActiveFocus();
       }
    }

    function removeConnection() {
        handler.removeConnection(pathToRemove)
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

    PlasmaNM.AppletProxyModel {
        id: appletProxyModel
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

    footer: RowLayout {
        Item {
            Layout.fillWidth: true
        }
        Button {
            id: reloadButton
            KeyNavigation.up: connectionView
            icon.name: "view-refresh"
            text: i18n("Refresh")
            onClicked: {
                networkSelectionView.refreshing = true;
                connectionView.contentY = -Kirigami.Units.gridUnit * 4;
            }
        }
    }

    Dialog {
        id: passwordLayer
        parent: networkSelectionView

        x: parent.width/2 - width/2
        y: Kirigami.Units.gridUnit
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
                Qt.inputMethod.show();
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
                    Layout.fillWidth: true
                    text: i18n("Forget")

                    onClicked: {
                        removeConnection()
                        networkActions.close()
                    }
                }
                Button {
                    Layout.fillWidth: true
                    text: i18n("Cancel")

                    onClicked: {
                        networkActions.close()
                    }
                }
            }
        }
    }

    ListView {
        id: connectionView

        activeFocusOnTab: true
        keyNavigationEnabled: true
        keyNavigationWraps: false
        focus: true
        model: appletProxyModel
        currentIndex: -1
        delegate: NetworkItem {}
        KeyNavigation.down: reloadButton
    }
}
