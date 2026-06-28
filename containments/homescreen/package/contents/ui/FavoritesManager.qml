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
import org.kde.layershell as LayerShell
import org.kde.plasma.plasmoid

Window {
    id: root
    title: i18n("Favorites Manager")

    LayerShell.Window.scope: "overlay"
    LayerShell.Window.anchors: LayerShell.Window.AnchorTop | LayerShell.Window.AnchorLeft | LayerShell.Window.AnchorRight | LayerShell.Window.AnchorBottom
    LayerShell.Window.layer: LayerShell.Window.LayerTop
    LayerShell.Window.exclusionZone: -1

    flags: Qt.FramelessWindowHint
    color: 'transparent'

    function showOverlay() {
        favsContainerAddSection.positionViewAtBeginning();
        favsContainerRemoveSection.positionViewAtBeginning();
        root.showFullScreen();
    }

    function hideOverlay() {
        root.close();
    }

    onActiveChanged: {
        if (!active) {
            hideOverlay();
        }
    }

    onVisibleChanged: {
        // Fade in when window is opening
        if (visible) {
            opacityAnim.to = 1;
            opacityAnim.restart();

            favsContainerAddSection.forceActiveFocus();
        }
    }

    onClosing: (close) => {
        // Fade out before closing
        if (windowContents.opacity !== 0) {
            close.accepted = false;
            opacityAnim.to = 0;
            opacityAnim.restart();
        }
    }

    // Search window contents
    Rectangle {
        id: windowContents
        anchors.fill: parent

        // Background color
        color: Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 0.8)

        opacity: 0
        NumberAnimation on opacity {
            id: opacityAnim
            duration: 400
            easing.type: Easing.OutCubic
            onFinished: {
                if (windowContents.opacity === 0) {
                    root.close();
                }
            }
        }

        Bigscreen.BackHandler.onActivated: root.hideOverlay()

        Kirigami.Theme.inherit: false
        Kirigami.Theme.colorSet: Kirigami.Theme.View

        // Background panel
        Rectangle {
            id: backgroundPanel
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: column.height - titleHeading.height - Kirigami.Units.gridUnit * 2
            color: Kirigami.Theme.backgroundColor
        }

        ColumnLayout {
            id: column
            anchors.fill: parent
            Kirigami.Heading {
                id: titleHeading
                Layout.fillWidth: true
                Layout.margins: Kirigami.Units.gridUnit
                text: root.title

                font.weight: Font.Light

                color: Kirigami.Theme.textColor
                fontSizeMode: Text.Fit
                minimumPixelSize: 16
                font.pixelSize: 32
            }

            RowLayout {
                Layout.fillHeight: true
                Layout.fillWidth: true

                ListView {
                    id: favsContainerAddSection

                    Layout.margins: Kirigami.Units.gridUnit
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    KeyNavigation.right: favsContainerRemoveSection

                    model: Plasmoid.applicationListModel
                    clip: true
                    keyNavigationEnabled: true
                    snapMode: ListView.SnapOneItem
                    spacing: Kirigami.Units.smallSpacing

                    Kirigami.Theme.inherit: false
                    Kirigami.Theme.colorSet: Kirigami.Theme.Window

                    header: Controls.Label {
                        text: i18n("Add Favorites")
                        font.pixelSize: Bigscreen.Units.headingFontPixelSize
                        elide: Text.ElideRight
                        bottomPadding: Kirigami.Units.largeSpacing
                    }

                    delegate: Bigscreen.ButtonDelegate {
                        width: favsContainerAddSection.width
                        text: model.ApplicationNameRole
                        icon.name: model.ApplicationIconRole
                        trailing: Kirigami.Icon {
                            source: "list-add-symbolic"
                            implicitWidth: Kirigami.Units.iconSizes.smallMedium
                            implicitHeight: Kirigami.Units.iconSizes.smallMedium
                        }
                        onClicked: {
                            FavsManager.addFav(Plasmoid.applicationListModel.itemMap(index));
                        }
                    }
                }

                ListView {
                    id: favsContainerRemoveSection

                    Layout.margins: Kirigami.Units.gridUnit
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    KeyNavigation.left: favsContainerAddSection

                    model: Plasmoid.favsListModel
                    clip: true
                    keyNavigationEnabled: true
                    snapMode: ListView.SnapOneItem
                    spacing: Kirigami.Units.smallSpacing

                    Kirigami.Theme.inherit: false
                    Kirigami.Theme.colorSet: Kirigami.Theme.Window

                    header: Controls.Label {
                        text: i18n("Remove Favorites")
                        font.pixelSize: Bigscreen.Units.headingFontPixelSize
                        elide: Text.ElideRight
                        bottomPadding: Kirigami.Units.largeSpacing
                    }

                    delegate: Bigscreen.ButtonDelegate {
                        width: favsContainerRemoveSection.width
                        text: model.ApplicationNameRole
                        icon.name: model.ApplicationIconRole
                        trailing: Kirigami.Icon {
                            source: "list-remove-symbolic"
                            implicitWidth: Kirigami.Units.iconSizes.smallMedium
                            implicitHeight: Kirigami.Units.iconSizes.smallMedium
                        }
                        onClicked: {
                            FavsManager.removeFav(Plasmoid.favsListModel.itemMap(index));
                        }
                    }
                }
            }
        }
    }
}
