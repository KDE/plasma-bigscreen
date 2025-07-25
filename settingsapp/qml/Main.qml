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

import org.kde.plasma.bigscreen.settings

Window {
    id: root

    flags: Qt.FramelessWindowHint
    color: 'transparent'

    property string currentModuleName
    property var loadedKCMPage: null

    property var settingsKCMMenu: menu.listView

    // Height of header components (shared between the two panes)
    readonly property real headerHeight: Kirigami.Units.gridUnit * 7

    Component.onCompleted: {
        KcmsListModel.loadKcms();

        if (SettingsApp.launchModule.length === 0) {
            showOverlay();
        } else {
            showOverlay(SettingsApp.launchModule);
        }
    }

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
        root.showFullScreen();

        timer.setTimeout(function () {
            // Force active focus on either the sidebar or content
            if ((moduleName === undefined) || (root.loadedKCMPage === null)) {
                root.settingsKCMMenu.forceActiveFocus();
            } else {
                root.loadedKCMPage.forceActiveFocus();
            }
        }, 100);

        if (moduleName === undefined) {
            openModule(KcmsListModel.get(0).kcmId);
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

        // Load page for KCM
        loadedKCMPage = kcmContainer.createObject(pageStack, {"kcm": module.kcm, "internalPage": module.kcm.mainUi});
        pageStack.push(loadedKCMPage);
        currentModuleName = module.name;
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

            KeyNavigation.right: loadedKCMPage
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

        Module {
            id: module
        }

        Component {
            id: kcmContainer

            KCMContainer {
                KeyNavigation.left: root.settingsKCMMenu
                KeyNavigation.backtab: KeyNavigation.left
                Keys.onEscapePressed: root.settingsKCMMenu.forceActiveFocus()

                onNewPageRequested: (page) => {
                    pageStack.push(kcmContainer.createObject(pageStack, {"internalPage": page}));
                }
            }
        }
    }
}
