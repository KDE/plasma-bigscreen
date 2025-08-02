/**
 * SPDX-FileCopyrightText: 2020 Nicolas Fella <nicolas.fella@gmx.de>
 * SPDX-FileCopyrightText: 2024 Shubham Arora <shubhamarora@protonmail.com>
 *
 * SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

.import org.kde.bluezqt as BluezQt

function deviceTypeToString(device) {
    switch (device.type) {
        case BluezQt.Device.Phone:
            return i18nc("This device is a Phone", "Phone");
        case BluezQt.Device.Modem:
            return i18nc("This device is a Modem", "Modem");
        case BluezQt.Device.Computer:
            return i18nc("This device is a Computer", "Computer");
        case BluezQt.Device.Network:
            return i18nc("This device is of type Network", "Network");
        case BluezQt.Device.Headset:
            return i18nc("This device is a Headset", "Headset");
        case BluezQt.Device.Headphones:
            return i18nc("This device is a Headphones", "Headphones");
        case BluezQt.Device.AudioVideo:
            return i18nc("This device is an Audio/Video device", "Multimedia");
        case BluezQt.Device.Keyboard:
            return i18nc("This device is a Keyboard", "Keyboard");
        case BluezQt.Device.Mouse:
            return i18nc("This device is a Mouse", "Mouse");
        case BluezQt.Device.Joypad:
            return i18nc("This device is a Game controller", "Game controller");
        case BluezQt.Device.Tablet:
            return i18nc("This device is a Graphics Tablet (input device)", "Tablet");
        case BluezQt.Device.Peripheral:
            return i18nc("This device is a Peripheral device", "Peripheral");
        case BluezQt.Device.Camera:
            return i18nc("This device is a Camera", "Camera");
        case BluezQt.Device.Printer:
            return i18nc("This device is a Printer", "Printer");
        case BluezQt.Device.Imaging:
            return i18nc("This device is an Imaging device (printer, scanner, camera, display, …)", "Imaging");
        case BluezQt.Device.Wearable:
            return i18nc("This device is a Wearable", "Wearable");
        case BluezQt.Device.Toy:
            return i18nc("This device is a Toy", "Toy");
        case BluezQt.Device.Health:
            return i18nc("This device is a Health device", "Health");
        default:
            const { uuids } = device;
            const profiles = [];

            if (uuids.includes(BluezQt.Services.ObexFileTransfer)) {
                profiles.push(i18n("File transfer"));
            }
            if (uuids.includes(BluezQt.Services.ObexObjectPush)) {
                profiles.push(i18n("Send file"));
            }
            if (uuids.includes(BluezQt.Services.HumanInterfaceDevice)) {
                profiles.push(i18n("Input"));
            }
            if (uuids.includes(BluezQt.Services.AdvancedAudioDistribution)) {
                profiles.push(i18n("Audio"));
            }
            if (uuids.includes(BluezQt.Services.Nap)) {
                profiles.push(i18n("Network"));
            }

            if (profiles.length === 0) {
                profiles.push(i18n("Other"));
            }

            return profiles.join(i18nc("List separator", ", "));
    }
}

function makeCall(call, cb) {
    call.finished.connect(cb);
}