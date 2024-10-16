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
    icon.name: "kdeconnect"
    property var window

    KDEConnect.DevicesModel {
        id: allDevicesModel
    }

    Repeater {
        model: allDevicesModel
        delegate: Item {
            property bool pairingRequest: device.isPairRequested || device.isPairRequestedByPeer ? 1 : 0
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
        configWindow.showOverlay("kcm_mediacenter_kdeconnect")
    }
}
