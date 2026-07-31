/*
 * SPDX-FileCopyrightText: 2026 User8395 <therealuser8395@proton.me>
 * SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL
*/

import QtQuick.Layouts
import QtQuick
import QtQuick.Window
import QtQuick.Controls as QQC2

import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import org.kde.bigscreen as Bigscreen
import org.kde.kdeconnect

Bigscreen.ScrollablePage {
    id: pluginsPage

    property QtObject currentDevice

    title: i18nc("%1 is the device name", "Plugin Settings for %1 ", currentDevice.name)
    
    leftPadding: Kirigami.Units.smallSpacing
    topPadding: Kirigami.Units.smallSpacing
    rightPadding: Kirigami.Units.smallSpacing
    bottomPadding: Kirigami.Units.smallSpacing

    Component.onCompleted: {
        pluginList.forceActiveFocus()
    }

    PluginModel {
        id: pluginModel
        deviceId: currentDevice.id()
    }

    ColumnLayout {
        KeyNavigation.left: root.KeyNavigation.left
        spacing: 0

        ListView {
            id: pluginList
            clip: true
            spacing: Kirigami.Units.smallSpacing

            Layout.fillWidth: true
            implicitHeight: contentHeight

            model: pluginModel            

            delegate: Bigscreen.SwitchDelegate {
                id: pluginDelegate
                width: model.configSource != "" ? pluginList.width - Kirigami.Units.gridUnit * 5 : pluginList.width
                KeyNavigation.right: model.configSource != "" ? pluginConfigButton : null

                text: model.name
                description: model.description
                icon.name: model.iconName
                checked: model.isChecked

                onToggled: model.isChecked = checked

                Bigscreen.ButtonDelegate {
                    id: pluginConfigButton
                    visible: model.configSource != "" 

                    width: Kirigami.Units.gridUnit * 5
                    height: pluginDelegate.height
                    anchors.left: pluginDelegate.right

                    onClicked: {
                        pluginConfigDialog.open()
                    }
                    
                    contentItem: Kirigami.Icon {
                        source: 'settings-configure'
                        Layout.alignment: Qt.AlignCenter
                    }

                    Bigscreen.Dialog {
                        id: pluginConfigDialog
                        title: model.name
                        standardButtons: Bigscreen.Dialog.Close

                        onOpened: pluginConfigLoader.forceActiveFocus()

                        contentItem: Loader {
                            id: pluginConfigLoader
                            source: model.configSource
                        }
                    }
                }
            }
        }
    }
}