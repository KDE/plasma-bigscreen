/*
    SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
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
            name: i18nd("org.kde.plasma.mycroft.bigscreen", "Wallpaper")
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
            highlightMoveDuration: Kirigami.Units.longDuration
            snapMode: ListView.SnapToItem
            model: imageWallpaper.wallpaperModel
            onCountChanged: currentIndex =  Math.min(model.indexOf(configDialog.wallpaperConfiguration["Image"]), model.rowCount()-1)
            KeyNavigation.left: headerItem
            Keys.onUpPressed: imageWallpaperDrawer.close()
            highlightRangeMode: ListView.ApplyRange
            
            preferredHighlightBegin: cellWidth
            preferredHighlightEnd: cellWidth
            displayMarginBeginning: cellWidth*2
            displayMarginEnd: cellWidth

            header: WallpaperDelegate {
                id: delegate
                width: wallpapersView.cellWidth
                height: wallpapersView.cellHeight

                readonly property int index: -1
                checked: activeFocus
                highlighted: configDialog.currentWallpaper = "org.kde.slideshow"
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

                contentItem: Image {
                    source: Qt.resolvedUrl("SlideshowThumbnail.png")
                    fillMode: Image.PreserveAspectCrop
                    sourceSize.width: width
                    sourceSize.height: height
                    Controls.Label {
                        anchors {
                            bottom: parent.bottom
                            horizontalCenter: parent.horizontalCenter
                        }
                        color: "white"
                        text: i18nd("org.kde.plasma.mycroft.bigscreen", "Slideshow")
                    }
                }

                Keys.onRightPressed: {
                    print(wallpapersView.itemAt(1, 1))
                    wallpapersView.itemAt(1, 1).forceActiveFocus()
                    wallpapersView.currentIndex = 0
                }
            }
    
            delegate: WallpaperDelegate {
                id: delegate

                highlighted: configDialog.wallpaperConfiguration["Image"] == model.path
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
