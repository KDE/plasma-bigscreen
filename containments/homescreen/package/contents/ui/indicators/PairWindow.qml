import QtQuick 2.9
import QtQuick.Window 2.3
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2 as Controls
import org.kde.kirigami 2.11 as Kirigami
import org.kde.kdeconnect 1.0 as KDEConnect

Window {
    id: root
    property QtObject currentDevice
    color: Qt.rgba(0, 0, 0, 0.8)

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
                text: "Pairing Request From " + currentDevice.name
            }

            RowLayout {
                Layout.fillWidth: true

                Controls.Button {
                    id: acceptButton
                    Layout.fillWidth: true
                    KeyNavigation.right: rejectButton
                    KeyNavigation.left: acceptButton
                    
                    background: Rectangle {
                        color: acceptButton.activeFocus ? Kirigami.Theme.highlightColor : Kirigami.Theme.backgroundColor
                    }
                    
                    contentItem: Item {
                        RowLayout {
                            anchors.centerIn: parent
                            Kirigami.Icon {
                                Layout.preferredWidth: Kirigami.Units.iconSizes.small
                                Layout.preferredHeight: Kirigami.Units.iconSizes.small
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

                Controls.Button {
                    id: rejectButton
                    Layout.fillWidth: true
                    KeyNavigation.right: rejectButton
                    KeyNavigation.left: acceptButton
                    
                    background: Rectangle {
                        color: rejectButton.activeFocus ? Kirigami.Theme.highlightColor : Kirigami.Theme.backgroundColor
                    }
                    
                    contentItem: Item {
                        RowLayout {
                            anchors.centerIn: parent
                            Kirigami.Icon {
                                Layout.preferredWidth: Kirigami.Units.iconSizes.small
                                Layout.preferredHeight: Kirigami.Units.iconSizes.small
                                source: "dialog-canel"
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
