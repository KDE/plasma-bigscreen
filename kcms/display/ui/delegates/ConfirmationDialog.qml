/*
    SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2019 Aditya Mehra <aix.m@outlook.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls as Controls
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami

Controls.Dialog {
    id: root
    width: Kirigami.Units.gridUnit * 50
    height: Kirigami.Units.gridUnit * 20
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2
    dim: true
    parent: displayKCMRoot
    property var selectedOutput
    property var selectedResolution
    property var selectedModeId

    onOpenedChanged: {
        if(opened){
            acceptButton.forceActiveFocus()
        }
    }

    background: Kirigami.ShadowedRectangle {
        color: Kirigami.Theme.backgroundColor
        radius: 6

        shadow {
            size: Kirigami.Units.largeSpacing
        }
    }
    
    contentItem: Item {
        id: contentItem
        anchors.fill: parent

        ColumnLayout {
            id: dialogLayout
            anchors.centerIn: parent
            width: parent.width * 0.5

            Kirigami.Heading {
                level: 1
                color: Kirigami.Theme.textColor
                text: i18n("New Resolution") + ": " + root.selectedResolution
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.minimumHeight: Kirigami.Units.gridUnit * 5
                spacing: Kirigami.Units.largeSpacing

                PlasmaComponents.Button {
                    id: acceptButton
                    Layout.fillWidth: true
                    Layout.minimumHeight: Kirigami.Units.gridUnit * 5

                    Keys.onRightPressed: {
                        rejectButton.forceActiveFocus()
                    }
                    
                    background: Kirigami.ShadowedRectangle {
                        color: acceptButton.activeFocus ? Kirigami.Theme.highlightColor : Kirigami.Theme.backgroundColor
                        radius: 3

                        shadow {
                            size: Kirigami.Units.largeSpacing
                        }
                    }
                    
                    contentItem: Item {
                        RowLayout {
                            anchors.centerIn: parent
                            Kirigami.Icon {
                                Layout.preferredWidth: Kirigami.Units.iconSizes.medium
                                Layout.preferredHeight: Kirigami.Units.iconSizes.medium
                                source: "dialog-ok"
                            }
                            Controls.Label {
                                text: i18n("Accept")
                            }
                        }
                    }
                                        
                    onClicked: (mouse)=> {
                        kcm.displayModel.setResolutionConfiguration(root.selectedModeId, root.selectedOutput)
                        root.close()
                        displayKCMRoot.forceActiveFocus()
                    }
                    
                    Keys.onReturnPressed: (event)=> {
                        clicked()
                    }

                }

                PlasmaComponents.Button {
                    id: rejectButton
                    Layout.fillWidth: true
                    Layout.minimumHeight: Kirigami.Units.gridUnit * 5

                    Keys.onLeftPressed: {
                        acceptButton.forceActiveFocus()
                    }

                    background: Kirigami.ShadowedRectangle {
                        color: rejectButton.activeFocus ? Kirigami.Theme.highlightColor : Kirigami.Theme.backgroundColor
                        radius: 3

                        shadow {
                            size: Kirigami.Units.largeSpacing
                        }
                    }
                    
                    contentItem: Item {
                        RowLayout {
                            anchors.centerIn: parent
                            Kirigami.Icon {
                                Layout.preferredWidth: Kirigami.Units.iconSizes.medium
                                Layout.preferredHeight: Kirigami.Units.iconSizes.medium
                                source: "dialog-cancel"
                            }
                            Controls.Label {
                                text: i18n("Cancel")
                            }
                        }
                    }
                    
                    onClicked: (mouse)=> {
                        root.close()
                        displayKCMRoot.forceActiveFocus()
                    }
                    
                    Keys.onReturnPressed: (event)=> {
                        clicked()
                    }
                }
            }
        }
    }
} 