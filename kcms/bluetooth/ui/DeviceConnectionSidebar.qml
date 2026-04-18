// SPDX-FileCopyrightText: 2025 User8395 <therealuser8395@proton.me>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import Qt5Compat.GraphicalEffects

import org.kde.kirigami as Kirigami
import org.kde.bigscreen as Bigscreen
import org.kde.bluezqt as BluezQt
import org.kde.plasma.components as PlasmaComponents

import "script.js" as Script

Bigscreen.SidebarOverlay {
    id: root
    openFocusItem: deviceInfoButton

    property var device: null

    property bool connecting: false
    property bool disconnecting: false

    header: Bigscreen.SidebarOverlayHeader {
        iconSource: device ? device.icon : ""
        title: device ? device.name : ""
    }

    content: ColumnLayout {
        id: colLayoutSettingsItem
        spacing: Kirigami.Units.smallSpacing

        Bigscreen.ButtonDelegate {
            id: deviceInfoButton
            icon.name: "info"
            text: i18n("Device information")
            description: desc()

            onClicked: infoDialog.open()
            KeyNavigation.down: connectToggleButton
            Keys.onLeftPressed: root.close()
        }

        Bigscreen.ButtonDelegate {
            id: connectToggleButton

            text: device ? (root.connecting ? i18n("Connecting…") : (root.disconnecting ? i18n("Disconnecting…") : (device.connected ? i18n("Disconnect") : (!device.paired ? i18n("Pair") : i18n("Connect"))))) : ""
            icon.name: device ? (device.connected ? "network-disconnect" : "network-connect") : ""

            KeyNavigation.down: forgetButton
            Keys.onLeftPressed: root.close()

            onClicked: {
                if (!device.paired) {
                    root.connecting = true;
                    Script.makeCall(device.pair(), call => {
                        root.connecting = false;
                        if (call.error) {
                            console.log("makeCall error when pairing: " + call.errorText)
                        }
                    });
                } else if (device.connected) {
                    root.disconnecting = true;
                    Script.makeCall(device.disconnectFromDevice(), call => {
                        root.disconnecting = false;
                        if (call.error) {
                            console.log("makeCall error when disconnecting: " + call.errorText);
                        }
                    });
                } else {
                    root.connecting = true;
                    Script.makeCall(device.connectToDevice(), call => {
                        root.connecting = false;
                        if (call.error) {
                            console.log("makeCall error when connecting: " + call.errorText);
                        }
                    });
                }
            }
        }

        Bigscreen.ButtonDelegate {
            id: forgetButton
            visible: device && device.paired
            text: i18n("Forget device")
            icon.name: "delete"

            KeyNavigation.down: trustedToggle
            Keys.onLeftPressed: root.close()

            onClicked: forgetDialog.open()

            Bigscreen.Dialog {
                id: forgetDialog
                standardButtons: Bigscreen.Dialog.Ok | Bigscreen.Dialog.Cancel
                title: i18n("Are you sure you want to forget the device %1?", device ? device.name : '')

                onAccepted: {
                    Script.makeCall(device.adapter.removeDevice(device), call => {
                        root.connecting = false;
                        if (call.error) {
                            console.log("makeCall error when forgetting: " + call.errorText);
                        }
                    });
                    forgetDialog.close();
                    root.close();
                }
                onRejected: {
                    forgetDialog.close();
                    forgetButton.forceActiveFocus();
                }
            }
        }

        Bigscreen.SwitchDelegate {
            id: trustedToggle
            visible: device && device.paired
            text: i18n("Trusted")
            description: i18n("Auto-accept incoming connections")
            checked: device && device.trusted

            KeyNavigation.down: blockedToggle
            Keys.onLeftPressed: root.close()

            onToggled: {
                device.trusted = checked;
            }
        }

        Bigscreen.SwitchDelegate {
            id: blockedToggle
            visible: device && device.paired
            text: i18n("Blocked")
            description: i18n("Reject all connections from this device")
            checked: device && device.blocked

            Keys.onLeftPressed: root.close()

            onToggled: {
                device.blocked = checked;
            }
        }

        Item {
            Layout.fillHeight: true
        }

        Bigscreen.Dialog {
            id: infoDialog
            title: i18n("Device details")

            onOpened: changeNameButton.forceActiveFocus()
            onClosed: deviceInfoButton.forceActiveFocus()

            contentItem: ColumnLayout {
                spacing: Kirigami.Units.smallSpacing

                QQC2.Label {
                    id: typeLabel
                    text: i18n("Type: %1", Script.deviceTypeToString(device))
                }

                QQC2.Label {
                    id: addressLabel
                    text: i18n("Address: %1", device ? device.address : "")
                }

                QQC2.Label {
                    id: batteryLabel
                    visible: device && device.battery
                    text: i18n("Battery: %1", device && device.battery ? device.battery.percentage + "%" : "")
                }

                Bigscreen.ButtonDelegate {
                    id: changeNameButton
                    text: i18n("Change name")
                    icon.name: "document-edit-symbolic"
                    visible: device && device.paired
                    onClicked: changeNameDialog.open()

                    Bigscreen.Dialog {
                        id: changeNameDialog
                        title: i18n("Change name")
                        standardButtons: Bigscreen.Dialog.Ok | Bigscreen.Dialog.Cancel

                        onOpened: nameTextField.forceActiveFocus()
                        onClosed: changeNameButton.forceActiveFocus()
                        onAccepted: {
                            device.name = nameTextField.text
                            changeNameDialog.close()
                        }

                        contentItem: ColumnLayout {
                            spacing: Kirigami.Units.smallSpacing

                            Bigscreen.TextField {
                                id: nameTextField
                                text: device ? device.name : ""
                                placeholderText: device ? device.name : ""
                                Keys.onReturnPressed: changeNameDialog.accept()
                                KeyNavigation.down: changeNameDialog.footer
                                Layout.fillWidth: true
                            }
                        }
                    }
                }
            }
        }
    }
}
