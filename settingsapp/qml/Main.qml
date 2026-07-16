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

    // Whether to have the sidebar shown at all times
    readonly property bool dualPanel: !visible || root.width > (minimumSidebarWidth * 2.5)

    readonly property real minimumSidebarWidth: Kirigami.Units.gridUnit * 20

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
        // Load the new module first so the previous KCM is deleted along with
        // its pages, before their containers get destroyed below
        module.path = path;

        // Collect the pages of the previously opened module, since the stack
        // does not own pages that were pushed as items
        const oldPages = [];
        for (let i = 0; i < pageStack.depth; ++i) {
            oldPages.push(pageStack.get(i));
        }

        // Load page for KCM, replacing all pages of the previous module
        loadedKCMPage = kcmContainer.createObject(pageStack, {"kcm": module.kcm, "internalPage": module.kcm.mainUi});
        pageStack.replace(null, loadedKCMPage);
        currentModuleName = module.name;

        // Destroy the old pages after the replace transition has finished
        for (const page of oldPages) {
            page.destroy(500);
        }
    }

    // Go up one page from the top of the KCM's page stack
    function popPage() {
        const page = pageStack.pop();
        if (page && page !== loadedKCMPage) {
            // Delay destruction so the pop transition can finish
            page.destroy(500);
        }
        if (pageStack.currentItem) {
            pageStack.currentItem.forceActiveFocus();
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
            width: Math.max(root.minimumSidebarWidth, parent.width * 0.20)

            currentModuleName: root.currentModuleName
            rightTarget: pageStack.currentItem

            KeyNavigation.right: pageStack.currentItem
            KeyNavigation.tab: KeyNavigation.right
            Bigscreen.BackHandler.onActivated: hideOverlay()
        }

        // Shadow
        Rectangle {
            width: Kirigami.Units.largeSpacing
            anchors.top: parent.top
            anchors.right: kcmContainerHolder.left
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

            x: menu.width
            y: 0
            height: parent.height
            width: root.dualPanel ? (parent.width - menu.width) : (parent.width)

            property real oldX: x
            property bool xIncreasing: false
            onXChanged: {
                xIncreasing = oldX < x;
                oldX = x;
            }

            // Implement panel slide with touch
            DragHandler {
                xAxis {
                    enabled: !root.dualPanel
                    minimum: 0
                    maximum: menu.width
                }
                yAxis.enabled: false

                onActiveChanged: {
                    if (!active) {
                        // Snap to end when touch stops
                        if (kcmContainerHolder.xIncreasing) {
                            settingsKCMMenu.forceActiveFocus();
                        } else if (pageStack.currentItem) {
                            pageStack.currentItem.forceActiveFocus();
                        }
                    }
                }
            }

            states: [
                State {
                    name: 'focused'
                    when: settingsKCMMenu.activeFocus
                    PropertyChanges { target: kcmContainerHolder; x: menu.width }
                },
                State {
                    name: 'notFocused'
                    when: !settingsKCMMenu.activeFocus
                    PropertyChanges { target: kcmContainerHolder; x: root.dualPanel ? menu.width : 0 }
                }
            ]

            transitions: [
                Transition {
                    NumberAnimation { properties: 'x'; duration: Kirigami.Units.longDuration; easing.type: Easing.OutExpo }
                }
            ]

            Controls.StackView {
                id: pageStack
                opacity: root.dualPanel ? 1 : (settingsKCMMenu.activeFocus ? 0.5 : 1)
                anchors.fill: parent

                // New pages move in from the right while fading in, and move back out when popped
                pushEnter: Transition {
                    ParallelAnimation {
                        PropertyAnimation { property: "opacity"; from: 0; to: 1; duration: Kirigami.Units.longDuration; easing.type: Easing.Linear }
                        PropertyAnimation { property: "x"; from: Kirigami.Units.gridUnit * 4; to: 0; duration: Kirigami.Units.veryLongDuration; easing.type: Easing.OutExpo }
                    }
                }
                pushExit: Transition {
                    PropertyAnimation { property: "opacity"; from: 1; to: 0; duration: 100 }
                }
                popEnter: Transition {
                    PropertyAnimation { property: "opacity"; from: 0; to: 1; duration: 100 }
                }
                popExit: Transition {
                    ParallelAnimation {
                        PropertyAnimation { property: "opacity"; from: 1; to: 0; duration: Kirigami.Units.longDuration; easing.type: Easing.Linear }
                        PropertyAnimation { property: "x"; from: 0; to: Kirigami.Units.gridUnit * 4; duration: Kirigami.Units.veryLongDuration; easing.type: Easing.OutExpo }
                    }
                }
                replaceEnter: Transition {
                    PropertyAnimation { property: "opacity"; from: 0; to: 1; duration: 100 }
                }
                replaceExit: Transition {
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

                // Go up one page if we are on a subpage, otherwise return to the sidebar
                Bigscreen.BackHandler.onActivated: {
                    if (isSubPage) {
                        goBack();
                    } else {
                        root.settingsKCMMenu.forceActiveFocus();
                    }
                }

                onNewPageRequested: (page) => {
                    const subPage = kcmContainer.createObject(pageStack, {"kcm": module.kcm, "internalPage": page, "isSubPage": true});
                    pageStack.push(subPage);
                    subPage.forceActiveFocus();
                }

                onPagePopRequested: root.popPage()

                onPageIndexChanged: (index) => {
                    // The KCM may jump back multiple pages at once by changing its current index
                    while (pageStack.depth > index + 1 && pageStack.depth > 1) {
                        root.popPage();
                    }
                }
            }
        }
    }
}
