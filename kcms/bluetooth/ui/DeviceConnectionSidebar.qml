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

    property var model: null

    property bool connecting: false
    property bool disconnecting: false

    header: Bigscreen.SidebarOverlayHeader {
        iconSource: model.Icon
        title: model ? model.Name : ""
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

            text: model ? (delegate.connecting ? i18n("Connecting…") : (delegate.disconnecting ? i18n("Disconnecting…") : (model.Connected ? i18n("Disconnect") : (!model.Paired ? i18n("Pair") : i18n("Connect"))))) : ""
            icon.name: model ? (model.Connected ? "network-disconnect" : "network-connect") : ""

            KeyNavigation.down: forgetButton
            Keys.onLeftPressed: root.close()

            onClicked: {
                if (!model.Paired) {
                    delegate.connecting = true;
                    Script.makeCall(model.Device.pair(), call => {
                        delegate.connecting = false;
                        if (call.error) {
                            console.log("makeCall error when pairing: " + call.errorText)
                        }
                    });
                } else if (model.Connected) {
                    delegate.disconnecting = true;
                    Script.makeCall(model.Device.disconnectFromDevice(), call => {
                        delegate.disconnecting = false;
                        if (call.error) {
                            console.log("makeCall error when disconnecting: " + call.errorText);
                        }
                    });
                } else {
                    delegate.connecting = true;
                    Script.makeCall(model.Device.connectToDevice(), call => {
                        delegate.connecting = false;
                        if (call.error) {
                            console.log("makeCall error when disconnecting: " + call.errorText);
                        }
                    });
                }
            }
        }

        Bigscreen.ButtonDelegate {
            id: forgetButton
            visible: model && model.Paired
            text: i18n("Forget device")
            icon.name: "delete"

            Keys.onLeftPressed: root.close()

            onClicked: forgetDialog.open()

            Bigscreen.Dialog {
                id: forgetDialog
                standardButtons: Bigscreen.Dialog.Ok | Bigscreen.Dialog.Cancel
                title: i18n("Are you sure you want to forget the device %1?", model ? model.Name : '')

                onAccepted: {
                    Script.makeCall(model.Device.adapter.removeDevice(model.Device), call => {
                        delegate.connecting = false;
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
                    text: i18n("Type: " + Script.deviceTypeToString(model.Device))
                }

                QQC2.Label {
                    id: addressLabel
                    text: i18n("Address: ") + model.Address
                }

                Bigscreen.ButtonDelegate {
                    id: changeNameButton
                    text: i18n("Change name")
                    icon.name: "document-edit-symbolic"
                    visible : model.Paired
                    onClicked: changeNameDialog.open()
                    
                    Bigscreen.Dialog {
                        id: changeNameDialog
                        title: i18n("Change name")
                        standardButtons: Bigscreen.Dialog.Ok | Bigscreen.Dialog.Cancel

                        onOpened: nameTextField.forceActiveFocus()
                        onClosed: changeNameButton.forceActiveFocus()
                        onAccepted: {
                            model.Device.name = nameTextField.text
                            changeNameDialog.close()
                        }

                        contentItem: ColumnLayout {
                            spacing: Kirigami.Units.smallSpacing

                            Bigscreen.TextField {
                                id: nameTextField
                                text: model.Name
                                placeholderText: model.Name
                                Keys.onReturnPressed: changeNameDialog.accept()
                                Layout.fillWidth: true
                            }
                        }
                    }
                }
            }
        }
    }
}
