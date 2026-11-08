// SPDX-FileCopyrightText: 2026 User8395 <therealuser8395@proton.me>
// SPDX-License-Identifier: GPL-2.0-only

import QtQuick
import QtQuick.Layouts
import QtQml.Models
import QtQuick.Controls as Controls

import org.kde.kirigami as Kirigami
import org.kde.bigscreen as Bigscreen
import org.kde.kdeconnect as KDEConnect
import org.kde.prison as Prison
import org.kde.bigscreen.shell as BigscreenShell

import org.kde.plasma.bigscreen.linkredirector

Window {
    id: window
    color: "transparent"
    flags: Qt.WindowStaysOnTopHint | Qt.FramelessWindowHint

    property string url

    Component.onCompleted: {
        showMaximized()
        dialog.open()
        if (devicesList.visible) devicesList.forceActiveFocus()
        else openInBrowserButton.forceActiveFocus()
        devicesList.currentIndex = 0
    }

    SortFilterProxyModel {
        id: devicesModel
        model: KDEConnect.DevicesModel {}

        filters: [
            ValueFilter {
                roleName: "status"
                value: KDEConnect.DevicesModel.Paired | KDEConnect.DevicesModel.Reachable
            },
        ]
    }

    Bigscreen.Dialog {
        id: dialog

        onRejected: window.close()
        onClosed: window.close()
        
        contentItem: ColumnLayout {
            spacing: Kirigami.Units.largeSpacing * 2

            Controls.Label {
                Layout.alignment: Qt.AlignHCenter
                Layout.maximumWidth: parent.implicitWidth
                font.pixelSize: Bigscreen.Units.headingFontPixelSize
                wrapMode: Text.WrapAnywhere
                text: window.url
            }

            RowLayout {
                ColumnLayout {
                    Layout.maximumWidth: parent.width / 2 - seperator.width

                    Controls.Label {
                        text: i18n("Choose a device to send the URL to:")
                        font.pixelSize: Bigscreen.Units.defaultFontPixelSize
                        wrapMode: Text.Wrap
                        visible: devicesList.visible
                        Layout.bottomMargin: Kirigami.Units.largeSpacing
                    }

                    Kirigami.InlineMessage {
                        id: errorMessage
                        type: Kirigami.MessageType.Error
                        Layout.fillWidth: true
                    }

                    ListView {
                        id: devicesList
                        model: devicesModel
                        visible: count > 0

                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.maximumHeight: Kirigami.Units.gridUnit * 25

                        keyNavigationEnabled: true
                        clip: true
                        KeyNavigation.down: openInBrowserButton

                        delegate: Bigscreen.ButtonDelegate {
                            icon.name: model.iconName
                            text: model.name
                            description: model.toolTip
                            width: devicesList.width
                            onClicked: {
                                let reply = LinkRedirector.sendUrl(model.deviceId, window.url)

                                if (reply === "ok") {
                                    window.close()
                                } else {
                                    errorMessage.text = i18nc("%1 is the device, %2 is the error message returned through dbus", "Failed to send URL to %1: %2", model.name, reply)
                                    errorMessage.visible = true
                                }
                            }
                        }
                    }

                    Kirigami.PlaceholderMessage {
                        visible: !devicesList.visible

                        icon.name: "edit-none"
                        text: i18nc("Shown in placeholder message if no devices are reachable", "No connected devices")
                        explanation: i18nc("Explanation of \"No connected devices\" placeholder", "Connect a device or check KDE Connect settings")

                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }
                }

                Rectangle {
                    id: seperator
                    width: 1
                    color: Kirigami.Theme.alternateBackgroundColor
                    
                    Layout.fillHeight: true
                    Layout.leftMargin: Kirigami.Units.largeSpacing * 2
                    Layout.rightMargin: Kirigami.Units.largeSpacing * 2
                    Layout.alignment: Qt.AlignHCenter
                    
                }

                ColumnLayout {
                    Layout.maximumWidth: parent.width / 2 - seperator.width

                    Controls.Label {
                        text: i18n("Scan the QR code below with a supported device:")
                        Layout.fillWidth: true
                        font.pixelSize: Bigscreen.Units.defaultFontPixelSize
                        wrapMode: Text.Wrap
                    }

                    Prison.Barcode {
                        id: urlQrCode
                        
                        Layout.fillWidth: true
                        Layout.preferredHeight: Kirigami.Units.gridUnit * 20

                        barcodeType: Prison.Barcode.QRCode
                        content: window.url
                    }
                }
            }

            Bigscreen.ButtonDelegate {
                id: openInBrowserButton
                text: i18n("Open in browser")
                icon.name: "open-link"
                Layout.fillWidth: true
                onClicked: {
                    LinkRedirector.openInBrowser(BigscreenShell.Settings.defaultBrowser, window.url)
                    window.close()
                }
            }
        }

        footer: Controls.DialogButtonBox {
            // When the dialog opens, focus is immediately sent to
            // the implicit dialog buttons, which isn't needed,
            // so create an invisible one that will give focus
            // to the devicesList.
            visible: false
            onActiveFocusChanged: {
                if (activeFocus) {
                    devicesList.forceActiveFocus()
                }
            }
        }
    }
}
