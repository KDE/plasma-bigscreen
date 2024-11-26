/*
    SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2019 Aditya Mehra <aix.m@outlook.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Window
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami
import org.kde.bigscreen as BigScreen
import org.kde.private.biglauncher 
import org.kde.plasma.private.nanoshell as NanoShell

NanoShell.FullScreenOverlay {
    id: overlay
    width: Screen.desktopAvailableWidth
    height: Screen.desktopAvailableHeight
    visible: false
    color: "transparent"
    property var currentModuleName
    property var loadedKCMPage: null

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
        if (!overlay.visible) {
            overlay.visible = true;
            timer.setTimeout(function () {
                menu.open();
                settingsKCMMenu.children[0].forceActiveFocus();
            }, 100);
        }

        if (moduleName === undefined) {
            openModule(plasmoid.kcmsListModel.get(0).kcmId);
        } else {
            openModule(moduleName);
        }
    }

    function hideOverlay() {
        if (overlay.visible) {
            timer.setTimeout(function () {
                menu.close();
            }, 200);
            overlay.visible = false;
        }
    }

    function openModule(path) {
        if (path.indexOf("kcm_mediacenter_wallpaper") != -1) {
            hideOverlay();
            root.configureWallpaper();
        }
        
        module.path = path;
        while (pageStack.count >= 1) {
            pageStack.clear();
        }
        loadedKCMPage = kcmContainer.createObject(pageStack, {"kcm": module.kcm, "internalPage": module.kcm.mainUi, "lastSettingMenuItem": settingItemAtLastIndex()});
        pageStack.push(loadedKCMPage);
        currentModuleName = module.name;
    }

    function settingItemAtLastIndex() {
        return settingsKCMMenu.children[settingsKCMMenu.lastIndex]
    }

    Module {
        id: module
    }


    Item {
        id: configContentItem
        anchors.fill: parent

        Kirigami.ShadowedRectangle {
            id: menu
            width: Screen.desktopAvailableWidth * 0.3
            height: parent.height
            color: Kirigami.Theme.backgroundColor
            opacity: 0
            x: -menu.width

            shadow {
                size: Kirigami.Units.largeSpacing * 2
            }

            function open() {
                menu.opacity = 1;
                menu.x = 0;
            }
            function close() {
                menu.opacity = 0;
                menu.x = -menu.width;
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: 50
                }
            }

            Behavior on x {
                NumberAnimation {
                    duration: 50
                }
            }

            Item {
                id: settingsHeader
                height: parent.height * 0.075
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: Kirigami.Units.largeSpacing

                Kirigami.Heading {
                    id: settingsTitle
                    text: i18n("Settings")
                    anchors.fill: parent
                    anchors.margins: Kirigami.Units.largeSpacing
                    verticalAlignment: Text.AlignBottom
                    horizontalAlignment: Text.AlignLeft
                    font.bold: true
                    color: Kirigami.Theme.textColor
                    fontSizeMode: Text.Fit
                    minimumPixelSize: 16
                    font.pixelSize: 32
                }
            }

            Item {
                id: settingsFooter
                height: Kirigami.Units.gridUnit * 4
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right

                Controls.Button {
                    id: kcmcloseButton
                    anchors.fill: parent

                    Keys.onUpPressed: {
                        settingsKCMMenu.children[settingsKCMMenuModel.count - 1].forceActiveFocus();
                    }

                    Keys.onDownPressed: {
                        settingsKCMMenu.children[0].forceActiveFocus();
                    }

                    Keys.onEscapePressed: hideOverlay()

                    background: Rectangle {
                        color: kcmcloseButton.activeFocus ? Kirigami.Theme.highlightColor : Kirigami.Theme.backgroundColor
                    }

                    contentItem: Item {
                        RowLayout {
                            anchors.centerIn: parent
                            Kirigami.Icon {
                                Layout.preferredWidth: Kirigami.Units.iconSizes.large
                                Layout.preferredHeight: Kirigami.Units.iconSizes.large
                                source: "window-close"
                            }
                            Controls.Label {
                                text: i18n("Close")
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignHCenter
                                fontSizeMode: Text.Fit
                                minimumPixelSize: 8
                                font.pixelSize: 18
                            }
                        }
                    }

                    onClicked: {
                        hideOverlay()
                    }

                    Keys.onReturnPressed: {
                        hideOverlay()
                    }
                }
            }

            Kirigami.Separator {
                id: settingsSeparator
                anchors.top: settingsHeader.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                Kirigami.Theme.colorSet: Kirigami.Theme.Button
                Kirigami.Theme.inherit: false
                color: Kirigami.Theme.backgroundColor
                height: 2
            }

            ColumnLayout {
                id: settingsKCMMenu
                anchors.top: settingsSeparator.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: Kirigami.Units.largeSpacing
                property var lastIndex: 0

                Repeater {
                    id: settingsKCMMenuModel
                    model: plasmoid.kcmsListModel

                    delegate: Controls.Button {
                        id: kcmButton
                        property var modelData: typeof model !== "undefined" ? model : null
                        Layout.fillWidth: true
                        Layout.preferredHeight: Kirigami.Units.gridUnit * 5
                        Keys.onEscapePressed: hideOverlay()

                        leftPadding: Kirigami.Units.gridUnit * 2

                        scale: kcmButton.activeFocus ? 0.96 : 1 
                        Behavior on scale {
                                NumberAnimation {
                                    duration: 100
                                }
                        }

                        onFocusChanged: {
                            if(focus) {
                                settingsKCMMenu.lastIndex = index;
                            }
                        }

                        Keys.onDownPressed: {
                            if (index < settingsKCMMenuModel.count - 1) {
                                settingsKCMMenu.children[index + 1].forceActiveFocus();
                            } else {
                                kcmcloseButton.forceActiveFocus();
                            }
                        }
                        Keys.onUpPressed: {
                            if (index > 0) {
                                settingsKCMMenu.children[index - 1].forceActiveFocus();
                            } else {
                                kcmcloseButton.forceActiveFocus();
                            }
                        }

                        KeyNavigation.right: loadedKCMPage

                        onClicked: {
                            openModule(modelData.kcmId);
                        }

                        Keys.onReturnPressed: {
                            openModule(modelData.kcmId);
                        }

                        background: Rectangle {
                            id: kcmButtonBackground
                            Kirigami.Theme.colorSet: Kirigami.Theme.Button
                            Kirigami.Theme.inherit: false
                            color: (modelData.kcmId === currentModuleName) ? Kirigami.Theme.highlightColor : Kirigami.Theme.backgroundColor
                            radius: Kirigami.Units.largeSpacing
                            border.color: kcmButton.activeFocus ? Kirigami.Theme.linkColor : ((modelData.kcmId === currentModuleName) ? Kirigami.Theme.highlightColor : Kirigami.Theme.backgroundColor)
                            border.width: 3        

                            Behavior on color {
                                ColorAnimation {
                                    duration: 100
                                }
                            }
                                         
                        }

                        contentItem: Item {                            
                            RowLayout {
                                id: kcmButtonLayout
                                anchors.fill: parent
                                spacing: Kirigami.Units.gridUnit

                                Kirigami.Icon {
                                    id: kcmButtonIcon
                                    source: modelData.kcmIconName
                                    Layout.alignment: Qt.AlignLeft
                                    Layout.preferredHeight: Kirigami.Units.iconSizes.large
                                    Layout.preferredWidth: kcmButtonIcon.height
                                }

                                Kirigami.Heading {
                                    id: kcmButtonLabel
                                    text: modelData.kcmName
                                    wrapMode: Text.WordWrap
                                    elide: Text.ElideRight
                                    Layout.alignment: Qt.AlignLeft
                                    Layout.fillWidth: true
                                }
                            }
                        }
                    }
                }
            }
        }

        Kirigami.ShadowedRectangle {
            id: kcmContainerHolder
            anchors.left: menu.right
            anchors.right: parent.right
            anchors.margins: Kirigami.Units.largeSpacing
            width: parent.width - menu.width
            height: parent.height
            color: Kirigami.Theme.backgroundColor
            opacity: kcmPresent ? 1 : 0
            property bool kcmPresent: true

            shadow {
                size: Kirigami.Units.largeSpacing * 2
            }

            Controls.StackView {
                id: pageStack
                anchors.fill: parent

                pushEnter: Transition {
                    PropertyAnimation {
                        property: "opacity"
                        from: 0
                        to:1
                        duration: 100
                    }
                }
                pushExit: Transition {
                    PropertyAnimation {
                        property: "opacity"
                        from: 1
                        to:0
                        duration: 100
                    }
                }
                popEnter: Transition {
                    PropertyAnimation {
                        property: "opacity"
                        from: 0
                        to:1
                        duration: 100
                    }
                }
                popExit: Transition {
                    PropertyAnimation {
                        property: "opacity"
                        from: 1
                        to:0
                        duration: 100
                    }
                }
            }
        }

        Component {
            id: kcmContainer
            Kirigami.Page {
                id: container

                property QtObject kcm
                property Item internalPage
                property Item lastSettingMenuItem
                property bool suppressDeletion: false

                title: internalPage.title

                header: Item {
                    id: headerAreaTop
                    height: parent.height * 0.075
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: Kirigami.Units.largeSpacing

                    Kirigami.Heading {
                        id: settingsTitle
                        text: internalPage.title
                        anchors.fill: parent
                        anchors.margins: Kirigami.Units.largeSpacing
                        verticalAlignment: Text.AlignBottom
                        horizontalAlignment: Text.AlignLeft
                        font.bold: true
                        color: Kirigami.Theme.textColor
                        fontSizeMode: Text.Fit
                        minimumPixelSize: 16
                        font.pixelSize: 32
                    }

                    Kirigami.Separator {
                        id: settingsSeparator
                        anchors.top: headerAreaTop.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        Kirigami.Theme.colorSet: Kirigami.Theme.Button
                        Kirigami.Theme.inherit: false
                        color: Kirigami.Theme.backgroundColor
                        height: 2
                    }
                }

                topPadding: 0
                leftPadding: 0
                rightPadding: 0
                bottomPadding: 0

                flickable: internalPage.flickable
                actions: [internalPage.actions.main, internalPage.contextualActions]

                onInternalPageChanged: {
                    internalPage.parent = contentItem;
                    internalPage.anchors.fill = contentItem;
                }
                onActiveFocusChanged: {
                    if (activeFocus) {
                        internalPage.forceActiveFocus();
                    }
                }

                Component.onCompleted: {
                    // setting a binding seems to not work, add them manually
                    for (let action of internalPage.actions) {
                        actions.push(action);
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
                        function onPageRemoved(page) {
                            if (kcm.needsSave) {
                                kcm.save();
                            }
                            if (page == container && !container.suppressDeletion) {
                                page.destroy();
                            }
                        }
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
