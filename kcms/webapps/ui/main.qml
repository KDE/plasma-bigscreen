// SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org
// SPDX-License-Identifier: GPL-2.0-or-later OR LicenseRef-KDE-Accepted-LGPL

import QtQuick
import QtQuick.Layouts
import QtQuick.Window
import QtQuick.Controls as QQC2

import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import org.kde.bigscreen as Bigscreen
import org.kde.bigscreen.webappskcm as WebAppsKCM

Kirigami.ScrollablePage {
    id: root

    title: i18n("Web Apps")

    leftPadding: Kirigami.Units.smallSpacing
    topPadding: 0
    rightPadding: Kirigami.Units.smallSpacing
    bottomPadding: 0

    onActiveFocusChanged: {
        if (activeFocus) {
            addWebApp.forceActiveFocus();
        }
    }

    ColumnLayout {
        spacing: Kirigami.Units.largeSpacing

        Bigscreen.FormButtonDelegate {
            id: addWebApp
            Layout.fillWidth: true

            onClicked: {
                addWebAppDialog.open()
                nameTextField.forceActiveFocus()
            }

            text: i18n('Add web app')
            icon.name: 'list-add'

            KeyNavigation.down: webAppListView
        }

        ListView {
            id: webAppListView
            implicitHeight: contentHeight
            spacing: Kirigami.Units.smallSpacing
            Layout.fillWidth: true

            KeyNavigation.up: addWebApp

            model: WebAppsKCM.WebAppManagerModel

            delegate: Bigscreen.FormButtonDelegate {
                icon.name: model.desktopIcon
                text: model.name
                description: model.url
                width: webAppListView.width

                onClicked: {
                    delegateInfoDialog.icon = model.desktopIcon;
                    delegateInfoDialog.name = model.name;
                    delegateInfoDialog.url = model.name;
                    delegateInfoDialog.userAgent = model.userAgent;
                    delegateInfoDialog.open();
                    nameButtonDelegate.forceActiveFocus();
                }
            }
        }
    }

    Bigscreen.OverlayDialog {
        id: addWebAppDialog
        title: i18n("Add web application")

        onAccepted: {
            WebAppsKCM.WebAppCreator.addEntry(nameTextField.text, urlTextField.text, 'internet-web-browser', userAgentTextField.text);
            close();
        }

        contentItem: ColumnLayout {
            spacing: Kirigami.Units.largeSpacing

            Bigscreen.FormTextField {
                id: nameTextField
                Layout.fillWidth: true
                placeholderText: i18n("Name")

                KeyNavigation.down: urlTextField
            }
            Bigscreen.FormTextField {
                id: urlTextField
                Layout.fillWidth: true
                placeholderText: i18n("URL")

                KeyNavigation.down: userAgentTextField
            }
            Bigscreen.FormTextField {
                id: userAgentTextField
                Layout.fillWidth: true
                placeholderText: i18n("User Agent")

                KeyNavigation.down: addWebAppDialog.footer
            }
        }
    }

    Bigscreen.OverlaySidebar {
        id: delegateInfoDialog

        property string icon
        property string name
        property string url
        property string userAgent

        header: ColumnLayout {
            spacing: Kirigami.Units.gridUnit
            Item { Layout.fillHeight: true }

            Kirigami.Icon {
                Layout.alignment: Qt.AlignHCenter
                implicitWidth: 128
                implicitHeight: 128
                source: delegateInfoDialog.icon
            }
            QQC2.Label {
                Layout.alignment: Qt.AlignHCenter
                font.pixelSize: 32
                font.weight: Font.Light
                text: delegateInfoDialog.name
            }
        }

        contentItem: ColumnLayout {
            spacing: Kirigami.Units.largeSpacing

            Bigscreen.FormButtonDelegate {
                id: nameButtonDelegate
                Layout.fillWidth: true
                text: i18n("Name")
                description: delegateInfoDialog.name

                KeyNavigation.down: urlButtonDelegate
                Keys.onLeftPressed: delegateInfoDialog.hideOverlay()
            }

            Bigscreen.FormButtonDelegate {
                id: urlButtonDelegate
                Layout.fillWidth: true
                text: i18n("URL")
                description: delegateInfoDialog.url

                KeyNavigation.down: descriptionButtonDelegate
                Keys.onLeftPressed: delegateInfoDialog.hideOverlay()
            }

            Bigscreen.FormButtonDelegate {
                id: descriptionButtonDelegate
                Layout.fillWidth: true
                text: i18n("User Agent")
                description: delegateInfoDialog.userAgent.length > 0 ? delegateInfoDialog.userAgent : i18n("Default user agent")

                KeyNavigation.down: deleteButtonDelegate
                Keys.onLeftPressed: delegateInfoDialog.hideOverlay()
            }
            Item { Layout.fillHeight: true }

            Bigscreen.FormButtonDelegate {
                id: deleteButtonDelegate
                Layout.fillWidth: true
                icon.name: 'delete'
                text: i18n("Delete")

                Keys.onLeftPressed: delegateInfoDialog.hideOverlay()

                onClicked: {
                    WebAppsKCM.WebAppManager.removeApp(delegateInfoDialog.name);
                }
            }
        }
    }
}
