import QtQuick 2.9
import QtQuick.Window 2.3
import QtQuick.Layouts 1.3
import QtQml.Models 2.2
import QtQuick.Controls 2.2 as Controls
import org.kde.kirigami 2.11 as Kirigami
import org.kde.kdeconnect 1.0 as KDEConnect
import org.kde.plasma.private.nanoshell 2.0 as NanoShell

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
            property bool pairingRequest: device.hasPairingRequests
            property var bigscreenIface: KDEConnect.BigscreenDbusInterfaceFactory.create(device.id())

            Connections {
                target: bigscreenIface
                onMessageReceived: message => {
                                       if (mycroftLoader.item) {
                                           mycroftLoader.item.sendText(message);
                                       }
                                   }
            }
            
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
                        console.log("Unknown Request")
                    }

                } else {
                    console.log("pairing request timedout/closed")
                    window.close()
                }
            }
        }
    }
    
    Loader {
        id: mycroftLoader
        source: Qt.resolvedUrl("MycroftConnect.qml") ? Qt.resolvedUrl("MycroftConnect.qml") : null
    }
    
    onClicked: {
        NanoShell.StartupFeedback.open(
                            "kdeconnect",
                            i18n("KDE Connect"),
                            connectionIcon.Kirigami.ScenePosition.x + connectionIcon.width/2,
                            connectionIcon.Kirigami.ScenePosition.y + connectionIcon.height/2,
                            Math.min(connectionIcon.width, connectionIcon.height));
        plasmoid.nativeInterface.executeCommand("plasma-settings -s -m kcm_mediacenter_kdeconnect")
    }
}
