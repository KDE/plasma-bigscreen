/*
    SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2019 Aditya Mehra <aix.m@outlook.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.14
import QtQuick.Window 2.14
import QtQuick.Layouts 1.14
import QtQuick.Controls 2.14 as Controls
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kirigami 2.12 as Kirigami
import org.kde.kdeconnect 1.0 as KDEConnect

Window {
    id: root
    property QtObject currentDevice
    color: Qt.rgba(0, 0, 0, 0.8)
    flags: Qt.WindowStaysOnTopHint

    Kirigami.Theme.colorSet: Kirigami.Theme.Complementary
    
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

            Kirigami.Heading {
                level: 3
                text: i18n("Pairing Request From %1", currentDevice.name)
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.minimumHeight: Kirigami.Units.gridUnit * 3

                PlasmaComponents.Button {
                    id: acceptButton
                    Layout.fillWidth: true
                    Layout.minimumHeight: Kirigami.Units.gridUnit * 3
                    KeyNavigation.right: rejectButton
                    KeyNavigation.left: acceptButton
                    
                    background: Rectangle {
                        color: acceptButton.activeFocus ? Kirigami.Theme.highlightColor : Kirigami.Theme.backgroundColor
                    }
                    
                    contentItem: Item {
                        RowLayout {
                            anchors.centerIn: parent
                            Kirigami.Icon {
                                Layout.preferredWidth: PlasmaCore.Units.iconSizes.small
                                Layout.preferredHeight: PlasmaCore.Units.iconSizes.small
                                source: "dialog-ok"
                            }
                            Controls.Label {
                                text: i18n("Accept")
                            }
                        }
                    }
                                        
                    onClicked: {
                        currentDevice.acceptPairing()
                        root.close()
                    }
                    
                    Keys.onReturnPressed: {
                        clicked()
                    }

                }

                PlasmaComponents.Button {
                    id: rejectButton
                    Layout.fillWidth: true
                    Layout.minimumHeight: Kirigami.Units.gridUnit * 3
                    KeyNavigation.right: rejectButton
                    KeyNavigation.left: acceptButton
                    
                    background: Rectangle {
                        color: rejectButton.activeFocus ? Kirigami.Theme.highlightColor : Kirigami.Theme.backgroundColor
                    }
                    
                    contentItem: Item {
                        RowLayout {
                            anchors.centerIn: parent
                            Kirigami.Icon {
                                Layout.preferredWidth: PlasmaCore.Units.iconSizes.small
                                Layout.preferredHeight: PlasmaCore.Units.iconSizes.small
                                source: "dialog-cancel"
                            }
                            Controls.Label {
                                text: i18n("Reject")
                            }
                        }
                    }
                    
                    onClicked: {
                        currentDevice.rejectPairing()
                        root.close()
                    }
                    
                    Keys.onReturnPressed: {
                        clicked()
                    }
                }
            }
        }
    }
} 
