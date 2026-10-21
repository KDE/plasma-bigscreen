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
    property string pendingPassword: ""
    property bool awaitingSecret: false

    Kirigami.Theme.inherit: false
    Kirigami.Theme.colorSet: Kirigami.Theme.Complementary

    function submitPassword(password) {
        if (awaitingSecret) {
            awaitingSecret = false;
            authenticator.respond(password);
        } else {
            pendingPassword = password;
            authenticator.startAuthenticating();
        }
    }

    function showPasswordDialog() {
        if (authenticator.unlocked) {
            Qt.quit();
            return;
        }
        passwordDialog.open();
        authenticator.startAuthenticating();
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
            root.awaitingSecret = false;
            root.notification = i18n("Unlocking failed");
            if (root.pendingPassword.length === 0) {
                passwordDialog.clear();
            }
            authenticator.startAuthenticating();
        }

        function onSucceeded() {
            authenticator.stopAuthenticating();
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
            if (authenticator.promptForSecret.length === 0) {
                return;
            }
            if (root.pendingPassword.length > 0) {
                Qt.callLater(() => {
                    authenticator.respond(root.pendingPassword);
                    root.pendingPassword = "";
                });
            } else {
                root.awaitingSecret = true;
            }
        }
    }

    // Keep the PAM backend active while the password dialog is shown
    Timer {
        interval: 1000
        repeat: true
        running: passwordDialog.opened && !authenticator.unlocked
        onTriggered: authenticator.startAuthenticating()
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

    TapHandler {
        enabled: !passwordDialog.opened
        onTapped: root.showPasswordDialog()
    }

    Keys.onPressed: (event) => {
        switch (event.key) {
        case Qt.Key_Up:
        case Qt.Key_Down:
        case Qt.Key_Left:
        case Qt.Key_Right:
        case Qt.Key_Return:
        case Qt.Key_Enter:
        case Qt.Key_Select:
        case Qt.Key_Space:
            root.showPasswordDialog();
            event.accepted = true;
            break;
        }
    }
}
