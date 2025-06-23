// SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
// SPDX-FileCopyrightText: 2019 Aditya Mehra <aix.m@outlook.com>
// SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Window
import QtQuick.Controls as Controls

import org.kde.kirigami as Kirigami
import org.kde.bigscreen as Bigscreen
import org.kde.private.biglauncher
import org.kde.plasma.private.nanoshell as NanoShell
import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.plasmoid

Window {
    id: root

    flags: Qt.FramelessWindowHint
    color: 'transparent'

    property string currentModuleName
    property var loadedKCMPage: null

    property var settingsKCMMenu: menu.listView

    // Height of header components (shared between the two panes)
    readonly property real headerHeight: Kirigami.Units.gridUnit * 7

    // HACK: some KCMs we don't want to navigate to because we lose focus
    // The about-distro KCM is not a native bigscreen kcm, so it eats keyboard inputs and softlocks us
    readonly property bool isCurrentModuleFocusable: currentModuleName != "kcm_about-distro"

    // Timer utility with callback
    Timer {
        id: timer
        function setTimeout(cb, delayTime) {
            timer.interval = delayTime;
            timer.repeat = false;
            timer.triggered.connect(cb);
            timer.triggered.connect(function release() {
                timer.triggered.disconnect(cb);
                timer.triggered.disconnect(release);
            });
            timer.start();
        }
    }

    function showOverlay(moduleName=undefined) {
        if (!root.visible) {
            root.showFullScreen();
            timer.setTimeout(function () {
                settingsKCMMenu.forceActiveFocus();
            }, 100);
        }

        if (moduleName === undefined) {
            openModule(plasmoid.kcmsListModel.get(0).kcmId);
        } else {
            openModule(moduleName);
        }
    }

    function hideOverlay() {
        if (root.visible) {
            root.close();
        }
    }

    // Open KCM with a given path
    function openModule(path) {
        module.path = path;
        while (pageStack.count >= 1) {
            pageStack.clear();
        }

        if (path.indexOf("kcm_mediacenter_wallpaper") != -1) {
            // HACK: Special page for wallpaper selector
            // TODO: create proper wallpaper KCM
            loadedKCMPage = wallpaperKcm.createObject(pageStack, {});
            pageStack.push(loadedKCMPage);
            currentModuleName = 'kcm_mediacenter_wallpaper';
        } else {
            // Load page for KCM
            loadedKCMPage = kcmContainer.createObject(pageStack, {"kcm": module.kcm, "internalPage": module.kcm.mainUi});
            pageStack.push(loadedKCMPage);
            currentModuleName = module.name;
        }
    }

    onVisibleChanged: {
        if (visible) {
            opacityAnim.to = 1;
            opacityAnim.restart();
        }
    }

    onClosing: (close) => {
        if (configContentItem.opacity !== 0) {
            close.accepted = false;
            opacityAnim.to = 0;
            opacityAnim.restart();
        }
    }

    Module {
        id: module
    }

    Item {
        id: configContentItem
        anchors.fill: parent

        opacity: 0
        NumberAnimation on opacity {
            id: opacityAnim
            duration: 400
            easing.type: Easing.OutCubic
            onFinished: {
                if (configContentItem.opacity === 0) {
                    root.close();
                }
            }
        }


        // Sidebar (left panel)
        ConfigWindowSidebar {
            id: menu
            headerHeight: root.headerHeight

            anchors.top: parent.top
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            width: Math.max(Kirigami.Units.gridUnit * 20, parent.width * 0.20)

            currentModuleName: root.currentModuleName

            KeyNavigation.right: root.isCurrentModuleFocusable ? loadedKCMPage : null
            KeyNavigation.tab: KeyNavigation.right
            Keys.onEscapePressed: hideOverlay()
        }

        // Shadow
        Rectangle {
            width: Kirigami.Units.largeSpacing
            anchors.top: parent.top
            anchors.right: menu.right
            anchors.bottom: parent.bottom
            opacity: 0.1

            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: 'transparent' }
                GradientStop { position: 1.0; color: 'black' }
            }
        }

        // Settings module (right panel)
        Rectangle {
            id: kcmContainerHolder
            color: Kirigami.Theme.backgroundColor

            anchors {
                left: menu.right
                right: parent.right
                top: parent.top
                bottom: parent.bottom
            }

            property bool kcmPresent: true

            Controls.StackView {
                id: pageStack
                anchors.fill: parent

                pushEnter: Transition {
                    PropertyAnimation { property: "opacity"; from: 0; to: 1; duration: 100 }
                }
                pushExit: Transition {
                    PropertyAnimation { property: "opacity"; from: 1; to: 0; duration: 100 }
                }
                popEnter: Transition {
                    PropertyAnimation { property: "opacity"; from: 0; to: 1; duration: 100 }
                }
                popExit: Transition {
                    PropertyAnimation { property: "opacity"; from: 1; to: 0; duration: 100 }
                }
            }
        }

        Component {
            id: wallpaperKcm
            Kirigami.Page {
                id: container

                KeyNavigation.left: root.isCurrentModuleFocusable ? root.settingsKCMMenu : null
                KeyNavigation.backtab: KeyNavigation.left

                onActiveFocusChanged: {
                    if (activeFocus) {
                        wallpaperSelectorDelegate.forceActiveFocus();
                    }
                }

                topPadding: 0
                leftPadding: Kirigami.Units.gridUnit + Kirigami.Units.largeSpacing
                rightPadding: leftPadding
                bottomPadding: 0

                header: Item {
                    id: headerAreaTop
                    height: root.headerHeight
                    width: parent.width

                    Kirigami.Heading {
                        id: settingsTitle
                        text: i18n('Wallpaper')
                        anchors.fill: parent

                        padding: container.leftPadding
                        verticalAlignment: Text.AlignBottom
                        horizontalAlignment: Text.AlignLeft

                        font.weight: Font.Light

                        color: Kirigami.Theme.textColor
                        fontSizeMode: Text.Fit
                        minimumPixelSize: 16
                        font.pixelSize: 32
                    }
                }

                ColumnLayout {
                    anchors.fill: parent

                    Bigscreen.ButtonDelegate {
                        id: wallpaperSelectorDelegate
                        Layout.fillWidth: true

                        // Open wallpaper selector
                        onClicked: {
                            root.hideOverlay();
                            Plasmoid.internalAction("configure").trigger();
                        }

                        text: i18n('Open wallpaper selector')
                        icon.name: 'backgroundtool'
                    }
                    Item { Layout.fillHeight: true }
                }
            }
        }

        Component {
            id: kcmContainer
            Kirigami.Page {
                id: container

                property QtObject kcm
                property Item internalPage
                property bool suppressDeletion: false

                title: internalPage.title

                KeyNavigation.left: root.isCurrentModuleFocusable ? root.settingsKCMMenu : null
                KeyNavigation.backtab: KeyNavigation.left
                Keys.onEscapePressed: root.settingsKCMMenu.forceActiveFocus()

                header: Item {
                    id: headerAreaTop
                    height: root.headerHeight
                    width: parent.width

                    Kirigami.Heading {
                        id: settingsTitle
                        text: internalPage ? internalPage.title : ''
                        anchors.fill: parent

                        padding: container.leftPadding
                        verticalAlignment: Text.AlignBottom
                        horizontalAlignment: Text.AlignLeft

                        font.weight: Font.Light

                        color: Kirigami.Theme.textColor
                        fontSizeMode: Text.Fit
                        minimumPixelSize: 16
                        font.pixelSize: 32
                    }
                }

                topPadding: 0
                leftPadding: Kirigami.Units.gridUnit + Kirigami.Units.largeSpacing
                rightPadding: leftPadding
                bottomPadding: 0

                flickable: internalPage ? internalPage.flickable : null
                actions: (internalPage && internalPage.actions) ? internalPage.actions : []

                onInternalPageChanged: {
                    if (internalPage) {
                        internalPage.parent = contentItem;
                        internalPage.anchors.fill = contentItem;

                        // Ensure pages have keynavigation set
                        internalPage.KeyNavigation.left = Qt.binding(() => container.KeyNavigation.left);
                    }
                }
                onActiveFocusChanged: {
                    if (activeFocus && internalPage && root.isCurrentModuleFocusable) {
                        internalPage.forceActiveFocus();
                    }
                    if (activeFocus && !root.isCurrentModuleFocusable) {
                        // Return focus to sidebar if this module is not focusable
                        root.settingsKCMMenu.forceActiveFocus();
                    }
                }

                Component.onCompleted: {
                    // setting a binding seems to not work, add them manually
                    if (internalPage && internalPage.actions) {
                        for (let action of internalPage.actions) {
                            actions.push(action);
                        }
                    }
                    if (kcm.load !== undefined) {
                        kcm.load();
                    }
                }

                data: [
                    Connections {
                        target: internalPage
                        function onActionsChanged() {
                            root.actions.clear();
                            for (let action of internalPage.actions) {
                                root.actions.push(action);
                            }
                        }
                    },
                    Connections {
                        target: kcm
                        function onPagePushed(page) {
                            pageStack.push(kcmContainer.createObject(pageStack, {"internalPage": page}));
                        }
                        function onPageRemoved() {
                            pageStack.pop();
                            hideOverlay();
                        }
                        function onNeedsSaveChanged() {
                            if (kcm.needsSave) {
                                kcm.save();
                            }
                        }
                    },
                    Connections {
                        target: pageStack
                        // TODO: this doesn't exist in StackView, find alternative
                        // function onPageRemoved(page) {
                        //     if (kcm.needsSave) {
                        //         kcm.save();
                        //     }
                        //     if (page == container && !container.suppressDeletion) {
                        //         page.destroy();
                        //     }
                        // }
                    },
                    Connections {
                        target: kcm
                        function onCurrentIndexChanged(index) {
                            const index_with_offset = index + 1;
                            if (index_with_offset !== pageStack.currentIndex) {
                                pageStack.currentIndex = index_with_offset;
                            }
                        }
                    }
                ]
            }
        }
    }
}
