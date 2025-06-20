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
                nameTextField.forceActiveFocus()
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

                header: ColumnLayout {

                }

                contentItem: ColumnLayout {

                }
            }
        }
    }
}
