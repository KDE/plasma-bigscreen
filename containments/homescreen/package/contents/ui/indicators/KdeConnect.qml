/*
    SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2019 Aditya Mehra <aix.m@outlook.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQml.Models
import org.kde.plasma.plasmoid
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami
import org.kde.kdeconnect as KDEConnect
import org.kde.plasma.private.nanoshell as NanoShell

AbstractIndicator {
    id: connectionIcon
    text: i18n('KDE Connect')
    icon.name: "phone-symbolic"
    property var window

    KDEConnect.DevicesModel {
        id: allDevicesModel
    }

    Repeater {
        model: allDevicesModel
        delegate: Item {
            property bool pairingRequest: device.isPairRequestedByPeer ? 1 : 0
            property var bigscreenIface: KDEConnect.BigscreenDbusInterfaceFactory.create(model.deviceId)

            onPairingRequestChanged: {
                if (pairingRequest) {
                    if(device.name.length > 0){
                        var component = Qt.createComponent("PairWindow.qml");
                        if (component.status != Component.Ready)
                        {
                            if (component.status == Component.Error) {
                                console.debug("Error: "+ component.errorString());
                            }
                            return;
                        } else {
                            window = component.createObject("root", {currentDevice: device})
                            window.show()
                            window.requestActivate()
                        }

                    } else {
                        console.debug("Unknown Request")
                    }

                } else {
                    window.close()
                }
            }
        }
    }

    onClicked: {
        Plasmoid.openSettings("kcm_mediacenter_kdeconnect")
    }
}
