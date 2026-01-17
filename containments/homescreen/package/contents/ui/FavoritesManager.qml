/*
    SPDX-FileCopyrightText: 2019 Aditya Mehra <aix.m@outlook.com>
    SPDX-FileCopyrightText: 2025 Seshan Ravikumar <seshan@sineware.ca>
    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Window
import QtQuick.Controls as Controls

import org.kde.kirigami as Kirigami
import org.kde.bigscreen as Bigscreen
import org.kde.private.biglauncher
import org.kde.plasma.private.nanoshell as NanoShell
import org.kde.plasma.core as PlasmaCore
import "launcher/delegates" as Delegates

Bigscreen.FullScreenOverlay {
    id: favoritesManagerOverlay
    title: i18n("Favorites Manager")
    initialFocusItem: favsContainerAddSection

    Item {
        anchors.fill: parent

        Kirigami.Theme.colorSet: Kirigami.Theme.View
        Kirigami.Theme.inherit: false

        Item {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.bottomMargin: Kirigami.Units.largeSpacing

            Rectangle {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.right: favsManagerSeparator.left
                color: Kirigami.Theme.alternateBackgroundColor

                Rectangle {
                    id: addFavHeader
                    anchors.top: parent.top
                    width: parent.width
                    height: Kirigami.Units.gridUnit * 4
                    color: Kirigami.Theme.backgroundColor
                    radius: 6

                    Controls.Label {
                        anchors.fill: parent
                        text: i18n("Add Favorites")
                        fontSizeMode: Text.Fit
                        minimumPixelSize: 8
                        font.pixelSize: 18
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        elide: Text.ElideRight
                        maximumLineCount: 1
                        color: Kirigami.Theme.textColor
                    }
                }

                ListView {
                    id: favsContainerAddSection
                    anchors.top: addFavHeader.bottom
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: Kirigami.Units.largeSpacing
                    model: plasmoid.applicationListModel
                    clip: true
                    keyNavigationEnabled: true
                    snapMode: ListView.SnapOneItem
                    KeyNavigation.down: closeButton
                    KeyNavigation.right: favsContainerRemoveSection
                    spacing: Kirigami.Units.smallSpacing

                    delegate: Delegates.FavManagerDelegate {
                        width: favsContainerAddSection.width
                        modelItem: model
                        modelActionIcon: "list-add-symbolic"

                        onClicked: {
                            FavsManager.addFav(plasmoid.applicationListModel.itemMap(index));
                        }
                    }
                }
            }

            Kirigami.Separator {
                id: favsManagerSeparator
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.centerIn: parent
                width: Kirigami.Units.largeSpacing
                color: "transparent"
            }

            Rectangle {
                anchors.left: favsManagerSeparator.right
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                color: Kirigami.Theme.backgroundColor

                Rectangle {
                    id: removeFavHeader
                    anchors.top: parent.top
                    width: parent.width
                    height: Kirigami.Units.gridUnit * 4
                    color: Kirigami.Theme.backgroundColor
                    radius: 6

                    Controls.Label {
                        anchors.fill: parent
                        text: i18n("Remove Favorites")
                        fontSizeMode: Text.Fit
                        minimumPixelSize: 8
                        font.pixelSize: 18
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        elide: Text.ElideRight
                        maximumLineCount: 1
                        color: Kirigami.Theme.textColor
                    }
                }

                ListView {
                    id: favsContainerRemoveSection
                    anchors.top: removeFavHeader.bottom
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: Kirigami.Units.largeSpacing
                    model: plasmoid.favsListModel
                    clip: true
                    keyNavigationEnabled: true
                    snapMode: ListView.SnapOneItem
                    KeyNavigation.left: favsContainerAddSection
                    KeyNavigation.down: closeButton
                    spacing: Kirigami.Units.smallSpacing

                    delegate: Delegates.FavManagerDelegate {
                        width: favsContainerRemoveSection.width
                        modelItem: model
                        modelActionIcon: "list-remove-symbolic"

                        onClicked: {
                            FavsManager.removeFav(plasmoid.favsListModel.itemMap(index));
                        }
                    }
                }
            }
        }

    }
}
