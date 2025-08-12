// SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org
// SPDX-License-Identifier: GPL-2.0-or-later OR LicenseRef-KDE-Accepted-LGPL

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2

import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import org.kde.bigscreen as Bigscreen
import org.kde.bigscreen.webappskcm as WebAppsKCM

Kirigami.ScrollablePage {
    id: root

    title: i18n("Web Apps")

    background: null
    leftPadding: Kirigami.Units.smallSpacing
    topPadding: Kirigami.Units.smallSpacing
    rightPadding: Kirigami.Units.smallSpacing
    bottomPadding: Kirigami.Units.smallSpacing

    onActiveFocusChanged: {
        if (activeFocus) {
            addWebApp.forceActiveFocus();
        }
    }

    ColumnLayout {
        KeyNavigation.left: root.KeyNavigation.left
        spacing: 0

        Bigscreen.ButtonDelegate {
            id: addWebApp
            raisedBackground: false

            onClicked: {
                addWebAppDialog.open()
                nameTextField.forceActiveFocus()
            }

            text: i18n("Add Web App")
            icon.name: 'list-add'

            KeyNavigation.down: webAppListView
        }

        QQC2.Label {
            text: i18n("Installed web apps")
            font.pixelSize: 22
            font.weight: Font.Normal
            Layout.fillWidth: true
            Layout.topMargin: Kirigami.Units.gridUnit
            Layout.bottomMargin: Kirigami.Units.gridUnit
        }

        ListView {
            id: webAppListView
            Layout.fillWidth: true

            implicitHeight: contentHeight
            model: WebAppsKCM.WebAppManagerModel
            currentIndex: 0
            spacing: Kirigami.Units.smallSpacing

            delegate: Bigscreen.ButtonDelegate {
                id: delegate
                raisedBackground: false

                icon.name: model.desktopIcon
                text: model.name
                description: model.url
                width: webAppListView.width

                onClicked: {
                    delegateInfoDialog.delegate = delegate
                    delegateInfoDialog.webAppId = model.id;
                    delegateInfoDialog.icon = model.desktopIcon;
                    delegateInfoDialog.name = model.name;
                    delegateInfoDialog.url = model.url;
                    delegateInfoDialog.userAgent = model.userAgent;
                    delegateInfoDialog.open();
                }
            }
        }

        Bigscreen.Dialog {
            id: addWebAppDialog
            title: i18n("Add Web Application")
            standardButtons: Bigscreen.Dialog.Ok | Bigscreen.Dialog.Cancel
            openFocusItem: nameTextField

            onClosed: addWebApp.forceActiveFocus()
            onAccepted: {
                WebAppsKCM.WebAppManagerModel.addEntry(nameTextField.text, urlTextField.text, 'internet-web-browser', userAgentTextField.text);
                close();
            }

            contentItem: ColumnLayout {
                spacing: Kirigami.Units.largeSpacing

                Bigscreen.TextField {
                    id: nameTextField
                    Layout.fillWidth: true
                    placeholderText: i18n("Name")

                    KeyNavigation.down: urlTextField
                }
                Bigscreen.TextField {
                    id: urlTextField
                    Layout.fillWidth: true
                    placeholderText: i18n("URL")

                    KeyNavigation.down: userAgentTextField
                }
                Bigscreen.TextField {
                    id: userAgentTextField
                    Layout.fillWidth: true
                    placeholderText: i18n("User agent (empty for default)")

                    KeyNavigation.down: addWebAppDialog.footer
                }
            }
        }

        WebAppInfoSidebar {
            id: delegateInfoDialog

            property var delegate
            onClosed: {
                if (delegate) {
                    delegate.forceActiveFocus();
                } else {
                    root.forceActiveFocus();
                }
            }
        }
    }
}
