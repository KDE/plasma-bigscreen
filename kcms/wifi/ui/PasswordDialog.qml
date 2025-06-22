// SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import QtQuick.Templates as T
import QtQuick.Effects

import org.kde.kirigami as Kirigami
import org.kde.bigscreen as Bigscreen
import org.kde.plasma.networkmanagement as PlasmaNM

Bigscreen.Dialog {
    id: root

    property string securityType
    property string connectionName
    property string devicePath
    property string specificPath

    title: i18n("Enter Password For %1", root.connectionName)
    openFocusItem: passField

    contentItem: ColumnLayout {
        implicitWidth: Kirigami.Units.gridUnit * 25

        Bigscreen.TextField {
            id: passField
            echoMode: TextInput.Password

            KeyNavigation.down: root.footer
            Layout.fillWidth: true
            placeholderText: i18n("Password…")
            validator: RegularExpressionValidator {
                regularExpression: if (root.securityType == PlasmaNM.Enums.StaticWep) {
                            /^(?:.{5}|[0-9a-fA-F]{10}|.{13}|[0-9a-fA-F]{26}){1}$/
                        } else {
                            /^(?:.{8,64}){1}$/
                        }
            }

            onAccepted: {
                handler.addAndActivateConnection(root.devicePath, root.specificPath, passField.text)
                root.close();
            }
        }
    }

    footer: Bigscreen.DialogButtonBox {
        dialog: root
        Bigscreen.Button {
            icon.name: 'dialog-ok'
            text: i18n("Connect")
            onClicked: passField.accepted();
        }
        Bigscreen.Button {
            icon.name: 'dialog-cancel'
            text: i18n("Cancel")
            onClicked: root.close()
        }
    }
}