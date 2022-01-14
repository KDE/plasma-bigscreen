/*

    SPDX-FileCopyrightText: 2017 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2011-2014 Sebastian Kügler <sebas@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.14
import QtQuick.Controls 2.14 as Controls
import org.kde.kirigami 2.12 as Kirigami

import org.kde.plasma.settings 0.1

import "+mediacenter" as MC

Kirigami.ApplicationWindow {
    id: rootItem

    pageStack.visible: pageStack.depth > 0
    pageStack.globalToolBar.style: Kirigami.ApplicationHeaderStyle.None

    color: Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 0.5)
    contextDrawer: Kirigami.ContextDrawer {
        id: contextDrawer
    }

    Component.onCompleted: {
        if (SettingsApp.startModule.length > 0) {
            module.name = SettingsApp.startModule
            var container = kcmContainer.createObject(pageStack, {"kcm": module.kcm, "internalPage": module.kcm.mainUi});
            pageStack.push(container);
        }
        if (modulesList.visible) {
            modulesList.forceActiveFocus();
            pageStack.KeyNavigation.up = modulesList
        }
    }

    Connections {
        target: SettingsApp
        onModuleRequested: {
            module.name = moduleName

            while (pageStack.depth > 1) {
                pageStack.pop()
            }

            var container = kcmContainer.createObject(pageStack, {"kcm": module.kcm, "internalPage": module.kcm.mainUi});
            pageStack.push(container);
        }
    }

    Module {
        id: module
    }

    header: ModulesListPage {
        id: modulesList
        visible: !SettingsApp.singleModule
        height: pageStack.depth > 0 ? Kirigami.Units.gridUnit * 15 : rootItem.height
        KeyNavigation.down: root.pageStack.visible ? root.pageStack : null
        Behavior on height {
            NumberAnimation {
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InOutQuad
            }
        }
    }
    

    Component {
        id: kcmContainer

        KCMContainer {}
    }
}
