/*
 *  Copyright 2019 Marco Martin <mart@kde.org>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  2.010-1301, USA.
 */

import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Layouts 1.0
import QtQuick.Controls 2.3 as Controls
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.configuration 2.0

//for the "simple mode"
import org.kde.plasma.wallpapers.image 2.0 as Wallpaper
import org.kde.kquickcontrolsaddons 2.0 as Addons
import org.kde.kcm 1.1 as KCM
import org.kde.kirigami 2.11 as Kirigami

AppletConfiguration {
    id: root
    isContainment: true

    internalDialog.visible: false
    internalDialog.width: Math.min(root.height - units.gridUnit * 2, Math.max(internalDialog.implicitWidth, units.gridUnit * 45))
    internalDialog.height: Math.min(root.width, Math.max(internalDialog.implicitHeight, units.gridUnit * 29))

    readonly property bool horizontal: false

//BEGIN model
    globalConfigModel: globalContainmentConfigModel

    ConfigModel {
        id: globalContainmentConfigModel
        ConfigCategory {
            name: i18nd("plasma_shell_org.kde.plasma.desktop", "Wallpaper")
            icon: "preferences-desktop-wallpaper"
            source: "ConfigurationContainmentAppearance.qml"
        }
    }
//END model

    Controls.Drawer {
        id: imageWallpaperDrawer
        edge: root.horizontal ? Qt.LeftEdge : Qt.BottomEdge
        visible: true
        onClosed: {
            if (!root.internalDialog.visible) {
                configDialog.close()
            }
        }
        onOpened: {
            wallpapersView.forceActiveFocus()
        }
        implicitWidth: units.gridUnit * 10
        implicitHeight: wallpapersView.cellHeight + topPadding + bottomPadding
        width: root.horizontal ? implicitWidth : root.width
        height: root.horizontal ? root.height : implicitHeight
        leftPadding: units.smallSpacing * 2
        rightPadding: units.smallSpacing * 2
        topPadding: units.smallSpacing * 2
        bottomPadding: units.smallSpacing * 2
        
        Wallpaper.Image {
            id: imageWallpaper
        }
        background: null

        ListView {
            id: wallpapersView
            anchors.fill: parent
            readonly property real cellWidth: width / Math.floor(width / (units.gridUnit * 12))
            readonly property int cellHeight: cellWidth / screenRatio
            readonly property real screenRatio: root.Window.window ? root.Window.window.width / root.Window.window.height : 1.6

            orientation: root.horizontal ? ListView.Vertical : ListView.Horizontal
            keyNavigationEnabled: true
            highlightFollowsCurrentItem: true
            snapMode: ListView.SnapToItem
            model: imageWallpaper.wallpaperModel
            onCountChanged: currentIndex =  Math.min(model.indexOf(configDialog.wallpaperConfiguration["Image"]), model.rowCount()-1)
            KeyNavigation.left: headerItem

            header: WallpaperDelegate {
                id: delegate
                width: wallpapersView.cellWidth
                height: wallpapersView.cellHeight

                highlight: activeFocus
                property bool isCurrent: configDialog.currentWallpaper = "org.kde.slideshow"
                onIsCurrentChanged: {
                    if (isCurrent) {
                        forceActiveFocus();
                        wallpapersView.currentIndex = -1;
                    }
                }
                onActiveFocusChanged: {
                    if (activeFocus) {
                        wallpapersView.currentIndex = -1;
                    }
                }
                onClicked: {
                    forceActiveFocus();
                    configDialog.currentWallpaper = "org.kde.slideshow";
                    configDialog.applyWallpaper();
                }
                Keys.onReturnPressed: clicked()

                contentItem: Rectangle {
                    ColumnLayout {
                        anchors.centerIn: parent
                        Item {
                            width: childrenRect.width
                            height: childrenRect.height
                            Repeater {
                                model: 4
                                Addons.QIconItem {
                                    x: modelData * 10 * (delegate.highlight ? 2 : 1)
                                    y: modelData * 10 * (delegate.highlight ? 2 : 1)
                                    z: 4 - modelData
                                    width: units.iconSizes.large
                                    height: width
                                    icon: "image-jpeg"
                                }
                            }
                        }
                        Controls.Label {
                            text: i18n("Slideshow")
                        }
                    }
                }

                Keys.onRightPressed: {
                    wallpapersView.currentIndex = 0
                    print(wallpapersView.itemAt(1, 1))
                    wallpapersView.itemAt(1, 1).forceActiveFocus()
                }
            }
    
            delegate: WallpaperDelegate {
                id: delegate

                property bool isCurrent: configDialog.wallpaperConfiguration["Image"] == model.path
                onIsCurrentChanged: {
                    if (isCurrent) {
                        wallpapersView.currentIndex = index;
                    }
                }
                
                contentItem: Item {
                    Addons.QIconItem {
                        anchors.centerIn: parent
                        width: units.iconSizes.large
                        height: width
                        icon: "view-preview"
                        visible: !walliePreview.visible
                    }

                    Addons.QPixmapItem {
                        id: walliePreview
                        anchors.fill: parent
                        visible: model.screenshot != null
                        smooth: true
                        pixmap: model.screenshot
                        fillMode: Image.PreserveAspectCrop
                    }
                }
                onClicked: {
                    configDialog.currentWallpaper = "org.kde.image";
                    configDialog.wallpaperConfiguration["Image"] = model.path;
                    configDialog.applyWallpaper()
                }
                Keys.onReturnPressed: {
                    clicked();
                }
            }
        }
    }
}
