/*
    SPDX-FileCopyrightText: 2019 Aditya Mehra <aix.m@outlook.com>
    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Controls
import org.kde.kirigami as Kirigami
import org.kde.breeze.components
import org.kde.plasma.private.sessions

Item {
    id: root
    property alias notification: messageDialog.text
    readonly property bool canBeUnlocked: authenticator.unlocked
    property string password: ""

    Kirigami.Theme.inherit: false
    Kirigami.Theme.colorSet: Kirigami.Theme.Complementary

    onPasswordChanged: {
        if (password.length > 0) {
            authenticator.startAuthenticating();
        }
    }

    Component.onCompleted: {
        root.forceActiveFocus();
    }
    
    Connections {
        target: authenticator

        function onFailed(kind) {
            if (kind != 0) {
                return;
            }
        }

        function onSucceeded() {
            passwordDialog.close();
            Qt.quit();
        }

        function onInfoMessageChanged() {
            root.notification = Qt.binding(() => authenticator.infoMessage);
        }
        function onErrorMessageChanged() {
            root.notification = Qt.binding(() => authenticator.errorMessage);
        }
        function onPromptForSecretChanged() {
            authenticator.respond(root.password);
        }
    }

    WallpaperFader {
        anchors.fill: parent
        state: root.visible ? "on" : "off"
        source: wallpaper
        mainStack: mainStack
        footer: footer
        clock: clock
    }

    StackView {
        id: mainStack
        anchors.fill: parent
        visible: true
        initialItem: Item {
            id: dialogArea

            MessageDialog {
                id: messageDialog
                anchors.top: parent.top
                anchors.topMargin: Kirigami.Units.gridUnit * 2
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width * 0.8
                height: Kirigami.Units.gridUnit * 4
            }

            PasswordDialog {
                id: passwordDialog
                anchors.top: messageDialog.bottom
                anchors.topMargin: Kirigami.Units.largeSpacing
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width * 0.8
                height: Kirigami.Units.gridUnit * 6
            }
        }
    }

    Clock {
        id: clock
        anchors.bottom: parent.bottom
        anchors.bottomMargin: parent.height * 0.15
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width * 0.6
        height: Kirigami.Units.gridUnit * 8
        visible: true
    }

    Item {
        id: footer
    }

    Keys.onPressed: (event) => {
        if (event.key === Qt.Key_Up || event.key === Qt.Key_Down || event.key === Qt.Key_Left || event.key === Qt.Key_Right || event.key === Qt.Key_Return) {
            if (authenticator.unlocked) {
                Qt.quit();
            } else {
                passwordDialog.open();
            }
        }
    }
}