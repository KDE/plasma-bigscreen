// SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org
// SPDX-License-Identifier: GPL-2.0-or-later OR LicenseRef-KDE-Accepted-LGPL

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2

import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import org.kde.bigscreen as Bigscreen
import org.kde.bigscreen.webappskcm as WebAppsKCM

Bigscreen.SidebarOverlay {
    id: root
    openFocusItem: nameButtonDelegate

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

        Bigscreen.ButtonDelegate {
            id: nameButtonDelegate
            text: i18n("Name")
            description: root.name

            KeyNavigation.down: urlButtonDelegate
        }

        Bigscreen.ButtonDelegate {
            id: urlButtonDelegate
            text: i18n("URL")
            description: root.url

            KeyNavigation.down: descriptionButtonDelegate
        }

        Bigscreen.ButtonDelegate {
            id: descriptionButtonDelegate
            text: i18n("User Agent")
            description: root.userAgent.length > 0 ? root.userAgent : i18n("Default user agent")

            KeyNavigation.down: deleteButtonDelegate
        }
        Item { Layout.fillHeight: true }

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
