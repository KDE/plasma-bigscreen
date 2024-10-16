/*
    SPDX-FileCopyrightText: 2019 Aditya Mehra <aix.m@outlook.com>
    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents

Item {
    id: passwordDialog
    property bool opened: false
    visible: opened
    enabled: opened
    opacity: opened ? 1 : 0

    function open() {
        opened = true
        passwordInput.text = ""
        passwordInput.forceActiveFocus()
    }

    function close() {
        opened = false
    }

    Behavior on opacity {
        NumberAnimation {
            property: "opacity"
            duration: 300
            from: 0
            to: 1
            easing.type: Easing.InOutQuad
        }
    }
    
    ColumnLayout {
        id: passwordLayout
        anchors.fill: parent
        spacing: Kirigami.Units.largeSpacing

        TextField {
            id: passwordInput
            placeholderText: i18n("Password")
            echoMode: TextInput.Password
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            font.weight: Font.Medium
            font.pointSize: Kirigami.Units.gridUnit * 3
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            KeyNavigation.tab: unlockButton
            KeyNavigation.down: unlockButton
            enabled: !authenticator.graceLocked

            background: Kirigami.ShadowedRectangle {
                color: Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 0.8)
                radius: 6
                border.width: passwordInput.activeFocus ? 2 : 0
                border.color: passwordInput.activeFocus ? Kirigami.Theme.highlightColor : "transparent"

                shadow {
                    size: Kirigami.Units.smallSpacing
                }
            }

            onAccepted: {
                root.password = passwordInput.text
            }
        }

        PlasmaComponents.Button {
            id: unlockButton
            text: i18n("Unlock Screen")
            padding: Kirigami.Units.largeSpacing * 2            
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            font.weight: Font.Medium
            font.pointSize: Kirigami.Units.gridUnit * 1.5
            KeyNavigation.tab: passwordInput
            KeyNavigation.up: passwordInput

            background: Kirigami.ShadowedRectangle {
                color: Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 0.8)
                radius: 6
                border.width: unlockButton.activeFocus ? 2 : 0
                border.color: unlockButton.activeFocus ? Kirigami.Theme.highlightColor : "transparent"

                shadow {
                    size: Kirigami.Units.smallSpacing
                }
            }

            onClicked: {
                root.password = passwordInput.text
            }
            Keys.onReturnPressed: clicked()
        }
    }
}