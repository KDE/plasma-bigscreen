// SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2

import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import org.kde.bigscreen as Bigscreen
import org.kde.bigscreen.webappskcm as WebAppsKCM

Bigscreen.SidebarOverlay {
    id: root
    openFocusItem: editButtonDelegate

    property string webAppId
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
            source: root.icon
        }
        QQC2.Label {
            text: root.name

            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            maximumLineCount: 2
            elide: Text.ElideRight
            font.pixelSize: 32
            font.weight: Font.Light
        }
    }

    content: ColumnLayout {
        spacing: Kirigami.Units.largeSpacing
        Keys.onLeftPressed: root.close()

        Bigscreen.TextDelegate {
            id: nameButtonDelegate
            text: i18n("Name")
            description: root.name
            raisedBackground: false
        }

        Bigscreen.TextDelegate {
            id: urlButtonDelegate
            text: i18n("URL")
            description: root.url
            raisedBackground: false
        }

        Bigscreen.TextDelegate {
            id: descriptionButtonDelegate
            text: i18n("User Agent")
            description: root.userAgent.length > 0 ? root.userAgent : i18n("Default user agent")
            raisedBackground: false
        }

        Item { Layout.fillHeight: true }

        Bigscreen.ButtonDelegate {
            id: editButtonDelegate
            icon.name: 'edit-entry'
            text: i18n("Edit")
            KeyNavigation.down: deleteButtonDelegate

            onClicked: editDialog.open()

            Bigscreen.Dialog {
                id: editDialog
                title: i18n("Edit web app %1", root.name)
                standardButtons: Bigscreen.Dialog.Save | Bigscreen.Dialog.Cancel
                openFocusItem: appNameField

                onRejected: editButtonDelegate.forceActiveFocus()

                onAccepted: {
                    if (appNameField.text == "") {
                        appNameField.text = root.name
                    }
                    WebAppsKCM.WebAppManagerModel.editApp(root.webAppId, appNameField.text, userAgentField.text)
                    root.name = appNameField.text
                    root.userAgent = userAgentField.text
                    editDialog.close()
                    editButtonDelegate.forceActiveFocus()
                }

                contentItem: ColumnLayout {
                    spacing: Kirigami.Units.largeSpacing

                    Bigscreen.TextField {
                        id: appNameField
                        Layout.fillWidth: true
                        placeholderText: i18nc("%1 is the current name of the web app", "Name (leave blank for current)", root.name)
                        text: root.name

                        KeyNavigation.down: userAgentField
                    }

                    Bigscreen.TextField {
                        id: userAgentField
                        Layout.fillWidth: true
                        placeholderText: i18nc("%1 is the user agent of the current web app", "User Agent (leave blank for default)", root.userAgent)
                        text: root.userAgent

                        KeyNavigation.down: editDialog.footer
                    }
                }
            }
        }

        Bigscreen.ButtonDelegate {
            id: deleteButtonDelegate
            icon.name: 'delete'
            text: i18n("Delete")

            onClicked: {
                deleteConfirmDialog.open();
            }

            Bigscreen.Dialog {
                id: deleteConfirmDialog
                title: i18n("Delete web app %1?", root.name)
                standardButtons: Bigscreen.Dialog.Ok | Bigscreen.Dialog.Cancel

                onAccepted: {
                    deleteConfirmDialog.close();
                    root.close();
                    WebAppsKCM.WebAppManagerModel.removeApp(root.webAppId);
                }
                onRejected: {
                    deleteButtonDelegate.forceActiveFocus();
                }
            }
        }
    }
}
