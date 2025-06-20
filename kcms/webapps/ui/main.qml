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

        Bigscreen.TileView {
            model: WebAppsKCM.WebAppManagerModel

            delegate: Bigscreen.KCMAbstractDelegate {
                highlighted: activeFocus
                Layout.fillWidth: true

                itemIcon: model.desktopIcon
                itemLabel: model.name
                itemSubLabel: model.url

                onClicked: {
                }
            }
        }

        Bigscreen.AbstractDelegate {
            id: addWebApp
            highlighted: activeFocus
            Layout.fillWidth: true

            onClicked: {
                addWebAppDialog.open()
            }

            contentItem: RowLayout {
                Kirigami.Heading {
                    Layout.fillWidth: true
                    text: i18n('Add web app')
                }
                Kirigami.Icon {
                    Layout.alignment: Qt.AlignCenter
                    source: 'list-add'
                    implicitWidth: Kirigami.Units.iconSizes.smallMedium
                    implicitHeight: Kirigami.Units.iconSizes.smallMedium
                }
            }

            Dialog {
                id: addWebAppDialog
                title: i18n("Add web application")
                standardButtons: Dialog.Ok | Dialog.Cancel

                onAccepted: {
                    WebAppsKCM.WebAppCreator.addEntry(nameTextField.text, urlTextField.text, 'internet-web-browser', userAgentTextField.text);
                    close();
                }

                contentItem: ColumnLayout {
                    QQC2.TextField {
                        id: nameTextField
                        placeholderText: i18n("Name")

                        KeyNavigation.down: urlTextField
                    }
                    QQC2.TextField {
                        id: urlTextField
                        placeholderText: i18n("URL")

                        KeyNavigation.down: userAgentTextField
                    }
                    QQC2.TextField {
                        id: userAgentTextField
                        placeholderText: i18n("User Agent")

                        KeyNavigation.down: addWebAppDialog.footer
                    }
                }
            }
        }
    }
}
