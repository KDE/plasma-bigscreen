/*
    SPDX-FileCopyrightText: 2019 Aditya Mehra <aix.m@outlook.com>
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

NanoShell.FullScreenOverlay {
    id: favoritesManagerOverlay
    width: Screen.desktopAvailableWidth
    height: Screen.desktopAvailableHeight
    visible: false
    color: "transparent"

    function showOverlay() {
        if (!favoritesManagerOverlay.visible) {
            favoritesManagerOverlay.visible = true;
            favsContainerAddSection.forceActiveFocus();
        }
    }

    function hideOverlay() {
        if (favoritesManagerOverlay.visible) {
            favoritesManagerOverlay.visible = false;
        }
    }
    
    Rectangle {
        id: windowBackgroundDimmer
        anchors.fill: parent
        color: Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 0.5)
    }

    Controls.Control {
        id: favsContainerHolder
        anchors.fill: parent
        anchors.margins: Kirigami.Units.largeSpacing * 4

        background: Kirigami.ShadowedRectangle {
            color: Kirigami.Theme.backgroundColor
            radius: 6
            shadow {
                size: Kirigami.Units.largeSpacing * 1
            }
        }

        contentItem: Item {
            Rectangle {
                id: favsManagerHeader
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: Kirigami.Units.gridUnit * 4
                color: Kirigami.Theme.backgroundColor

                Controls.Label {
                    anchors.fill: parent
                    text: i18n("Favorites Manager")
                    fontSizeMode: Text.Fit
                    minimumPixelSize: 8
                    font.pixelSize: 24
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    elide: Text.ElideRight
                    maximumLineCount: 1
                    color: Kirigami.Theme.textColor
                }
            }

            Rectangle {
                anchors.left: parent.left
                anchors.top: favsManagerHeader.bottom
                anchors.bottom: closeButton.top
                anchors.margins: Kirigami.Units.largeSpacing
                anchors.right: favsManagerSeparator.left
                color: Kirigami.Theme.alternateBackgroundColor

                Rectangle {
                    id: addFavHeader
                    anchors.top: parent.top
                    width: parent.width
                    height: Kirigami.Units.gridUnit * 4
                    color: Kirigami.Theme.backgroundColor
                    radius: 6
                    border.color: Kirigami.Theme.disabledTextColor
                    border.width: 1

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

                        onClicked: {
                            plasmoid.FavsManager.addFav(plasmoid.applicationListModel.itemMap(index));
                        }
                    }
                }
            }

            Kirigami.Separator {
                id: favsManagerSeparator
                anchors.top: favsManagerHeader.bottom
                anchors.bottom: closeButton.top
                anchors.centerIn: parent
                width: Kirigami.Units.largeSpacing
                color: "transparent"
            }

            Rectangle {
                anchors.left: favsManagerSeparator.right
                anchors.right: parent.right
                anchors.top: favsManagerHeader.bottom
                anchors.bottom: closeButton.top
                anchors.margins: Kirigami.Units.largeSpacing
                color: Kirigami.Theme.alternateBackgroundColor

                Rectangle {
                    id: removeFavHeader
                    anchors.top: parent.top
                    width: parent.width
                    height: Kirigami.Units.gridUnit * 4
                    color: Kirigami.Theme.backgroundColor
                    radius: 6
                    border.color: Kirigami.Theme.disabledTextColor
                    border.width: 1


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

                        onClicked: {
                            plasmoid.FavsManager.removeFav(plasmoid.favsListModel.itemMap(index));
                        }
                    }
                }
            }

            Controls.Button {
                id: closeButton
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: Kirigami.Units.gridUnit * 4

                background: Kirigami.ShadowedRectangle {
                    color: closeButton.activeFocus ? Kirigami.Theme.highlightColor : Kirigami.Theme.backgroundColor
                    radius: 6
                    shadow {
                        size: Kirigami.Units.largeSpacing * 1
                    }
                }

                contentItem: Item {
                    RowLayout {
                        anchors.centerIn: parent
                        Kirigami.Icon {
                            Layout.fillHeight: true
                            Layout.preferredWidth: height
                            source: "window-close"
                        }
                        Controls.Label {
                            fontSizeMode: Text.Fit
                            minimumPixelSize: 8
                            font.pixelSize: 18
                            text: i18n("Close")
                        }
                    }
                }

                onClicked: hideOverlay()
                Keys.onReturnPressed: hideOverlay()
            }
        }
    }
}
