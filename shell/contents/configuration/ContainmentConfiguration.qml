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
import QtQuick.Layouts 1.0
import QtQuick.Controls 2.3 as Controls
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.configuration 2.0

//for the "simple mode"
import org.kde.plasma.wallpapers.image 2.0 as Wallpaper
import org.kde.kquickcontrolsaddons 2.0 as Addons
import org.kde.kcm 1.1 as KCM

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
        implicitHeight: units.gridUnit * 8
        width: root.horizontal ? implicitWidth : root.width
        height: root.horizontal ? root.height : implicitHeight
        Wallpaper.Image {
            id: imageWallpaper
        }
        background: null

        ListView {
            id: wallpapersView
            anchors.fill: parent
            orientation: root.horizontal ? ListView.Vertical : ListView.Horizontal
            keyNavigationEnabled: true
            highlightFollowsCurrentItem: true
            snapMode: ListView.SnapToItem
            model: imageWallpaper.wallpaperModel
            onCountChanged: currentIndex =  Math.min(model.indexOf(configDialog.wallpaperConfiguration["Image"]), model.rowCount()-1)

            delegate: Controls.ItemDelegate {
                width: root.horizontal ? parent.width : height * 1.6
                height: root.horizontal ? width / 1.6 : parent.height
                

                property bool isCurrent: configDialog.wallpaperConfiguration["Image"] == model.path
                onIsCurrentChanged: {
                    if (isCurrent) {
                        wallpapersView.currentIndex = index;
                    }
                }
                
                z: wallpapersView.currentIndex === index ? 2 : 0
                Addons.QIconItem {
                    anchors.centerIn: parent
                    width: units.iconSizes.large
                    height: width
                    icon: "view-preview"
                    visible: !walliePreview.visible
                }

                Addons.QPixmapItem {
                    id: walliePreview
                    anchors {
                        fill: parent
                        margins: wallpapersView.currentIndex === index ? -units.gridUnit : 0
                        Behavior on margins {
                            NumberAnimation {
                                duration: units.longDuration
                                easing.type: Easing.InOutQuad
                            }
                        }
                    }
                    visible: model.screenshot != null
                    smooth: true
                    pixmap: model.screenshot
                    fillMode: Image.PreserveAspectCrop
                }
                onClicked: {
                    configDialog.currentWallpaper = "org.kde.image";
                    configDialog.wallpaperConfiguration["Image"] = model.path;
                    configDialog.applyWallpaper()
                }
                Keys.onReturnPressed: {
                    clicked();
                }
                background: Rectangle {
                    color: "lightGray"
                    opacity: 0.8
                }
            }
        }
    }
}
