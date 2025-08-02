// SPDX-FileCopyrightText: 2025 User8395 <therealuser8395@proton.me>
// SPDX-License-Identifier: GPL-2.0-or-later

// Some functions in this KCM were taken from the
// Plasma Desktop Bluetooth KCM (plasma/bluedevil).
// All credit goes to the respective authors.

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls as QQC2

import org.kde.kirigami as Kirigami
import org.kde.bluezqt as BluezQt
import org.kde.kcmutils as KCM
import org.kde.bigscreen as Bigscreen

import org.kde.plasma.bigscreen.bluetooth

Kirigami.ScrollablePage {
    id: bluetoothView

    title: i18n("Bluetooth")
    background: null

    leftPadding: Kirigami.Units.smallSpacing
    topPadding: Kirigami.Units.smallSpacing
    rightPadding: Kirigami.Units.smallSpacing
    bottomPadding: Kirigami.Units.smallSpacing

    property BluezQt.Manager manager: BluezQt.Manager

    Connections {
        target: manager

        onUsableAdapterChanged: {
            manager.usableAdapter.startDiscovery();
        }
    }

    onActiveFocusChanged: {
        if (activeFocus) {
            bluetoothToggle.forceActiveFocus();
        }
    }

    DevicesProxyModel {
        id: pairedDevicesModel
        pairedOnly: true
        sourceModel: BluezQt.DevicesModel {}
    }

    DevicesProxyModel {
        id: unpairedDevicesModel
        pairedOnly: false
        sourceModel: BluezQt.DevicesModel {}
    }

    ColumnLayout {
        KeyNavigation.left: bluetoothView.KeyNavigation.left
        id: column
        spacing: 0

        Bigscreen.SwitchDelegate {
            id: bluetoothToggle
            raisedBackground: false
            text: i18n("Enable Bluetooth")
            icon.name: "network-bluetooth"
            checked: BluezQt.Manager.bluetoothOperational
            onClicked: {
                const bluetoothStatus = checked;

                BluezQt.Manager.bluetoothBlocked = !bluetoothStatus;
                BluezQt.Manager.adapters.forEach(adapter => {
                    adapter.powered = !bluetoothStatus;
                });

                checked = Qt.binding(() => BluezQt.Manager.bluetoothOperational);
            }

            KeyNavigation.down: pairedDelegateList
        }

        QQC2.Label {
            id: pairedLabel
            text: i18n("Paired devices")
            visible: BluezQt.Manager.bluetoothOperational
            font.pixelSize: 22
            font.weight: Font.Normal
            Layout.topMargin: Kirigami.Units.gridUnit
            Layout.bottomMargin: Kirigami.Units.smallSpacing
        }

        ListView {
            id: pairedDelegateList
            Layout.fillWidth: true
            implicitHeight: contentHeight
            spacing: Kirigami.Units.smallSpacing
            visible: BluezQt.Manager.bluetoothOperational
            KeyNavigation.down: unpairedDelegateList

            clip: true
            model: pairedDevicesModel
            delegate: DeviceDelegate {
                id: pairedDelegate
                width: pairedDelegateList.width
                smallDescription: true
                raisedBackground: false

                onClicked: {
                    sidebarOverlay.delegate = pairedDelegate;
                    sidebarOverlay.model = model;
                    sidebarOverlay.open();
                }
            }
        }

        QQC2.Label {
            id: unpairedLabel
            text: i18n("Available devices")
            visible: BluezQt.Manager.bluetoothOperational
            font.pixelSize: 22
            font.weight: Font.Normal
            Layout.topMargin: Kirigami.Units.gridUnit
            Layout.bottomMargin: Kirigami.Units.smallSpacing
        }

        ListView {
            id: unpairedDelegateList
            Layout.fillWidth: true
            implicitHeight: contentHeight
            spacing: Kirigami.Units.smallSpacing
            visible: BluezQt.Manager.bluetoothOperational
            KeyNavigation.up: pairedDelegateList

            clip: true
            model: unpairedDevicesModel
            delegate: DeviceDelegate {
                id: unpairedDelegate
                width: pairedDelegateList.width
                smallDescription: true
                raisedBackground: false

                onClicked: {
                    sidebarOverlay.delegate = unpairedDelegate;
                    sidebarOverlay.model = model;
                    sidebarOverlay.open();
                }
            }
        }

        DeviceConnectionSidebar {
            id: sidebarOverlay

            property var delegate
            onClosed: delegate.forceActiveFocus()
        }
    }
}
