/*
    SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2019 Aditya Mehra <aix.m@outlook.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls as Controls
import org.kde.kdeconnect as KDEConnect
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami

Window {
    id: root
    property QtObject currentDevice
    property bool pairingRequest: currentDevice.isPairRequestedByPeer ? 1 : 0
    color: Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 0.7)
    flags: Qt.WindowStaysOnTopHint | Qt.FramelessWindowHint

    onClosing: {
        if(pairingRequest){
            currentDevice.cancelPairing()
        }
    }
    
    onVisibleChanged: {
        if(visible){
            showMaximized()
            acceptButton.forceActiveFocus()
        }
    }
    
    Item {
        id: contentItem
        anchors.fill: parent

        ColumnLayout {
            id: pairingDialogLayout
            anchors.centerIn: parent
            width: parent.width * 0.5

            Kirigami.Heading {
                level: 1
                color: Kirigami.Theme.textColor
                text: i18n("Pairing Request From %1", currentDevice.name)
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.minimumHeight: Kirigami.Units.gridUnit * 5
                spacing: Kirigami.Units.largeSpacing

                PlasmaComponents.Button {
                    id: acceptButton
                    Layout.fillWidth: true
                    Layout.minimumHeight: Kirigami.Units.gridUnit * 5

                    Keys.onRightPressed: {
                        rejectButton.forceActiveFocus()
                    }
                    
                    background: Kirigami.ShadowedRectangle {
                        color: acceptButton.activeFocus ? Kirigami.Theme.highlightColor : Kirigami.Theme.backgroundColor
                        radius: 3

                        shadow {
                            size: Kirigami.Units.largeSpacing
                        }
                    }
                    
                    contentItem: Item {
                        RowLayout {
                            anchors.centerIn: parent
                            Kirigami.Icon {
                                Layout.preferredWidth: Kirigami.Units.iconSizes.medium
                                Layout.preferredHeight: Kirigami.Units.iconSizes.medium
                                source: "dialog-ok"
                            }
                            Controls.Label {
                                text: i18n("Accept")
                            }
                        }
                    }
                                        
                    onClicked: (mouse)=> {
                        currentDevice.acceptPairing()
                        pairingRequest = false
                        root.close()
                    }
                    
                    Keys.onReturnPressed: (event)=> {
                        clicked()
                    }

                }

                PlasmaComponents.Button {
                    id: rejectButton
                    Layout.fillWidth: true
                    Layout.minimumHeight: Kirigami.Units.gridUnit * 5

                    Keys.onLeftPressed: {
                        acceptButton.forceActiveFocus()
                    }

                    background: Kirigami.ShadowedRectangle {
                        color: rejectButton.activeFocus ? Kirigami.Theme.highlightColor : Kirigami.Theme.backgroundColor
                        radius: 3

                        shadow {
                            size: Kirigami.Units.largeSpacing
                        }
                    }
                    
                    contentItem: Item {
                        RowLayout {
                            anchors.centerIn: parent
                            Kirigami.Icon {
                                Layout.preferredWidth: Kirigami.Units.iconSizes.medium
                                Layout.preferredHeight: Kirigami.Units.iconSizes.medium
                                source: "dialog-cancel"
                            }
                            Controls.Label {
                                text: i18n("Cancel")
                            }
                        }
                    }
                    
                    onClicked: (mouse)=> {
                        currentDevice.cancelPairing()
                        pairingRequest = false
                        root.close()
                    }
                    
                    Keys.onReturnPressed: (event)=> {
                        clicked()
                    }
                }
            }
        }
    }
} 