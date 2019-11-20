/***************************************************************************
 *                                                                         *
 *   Copyright 2017 Marco Martin <mart@kde.org>                            *
 *   Copyright 2011-2014 Sebastian Kügler <sebas@kde.org>                  *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 ***************************************************************************/

import QtQuick 2.6
import QtQuick.Controls 2.2 as Controls
import org.kde.kirigami 2.5 as Kirigami

import org.kde.plasma.settings 0.1

Kirigami.ApplicationWindow {
    id: rootItem

    pageStack.visible: pageStack.depth > 0
    pageStack.globalToolBar.style: Kirigami.ApplicationHeaderStyle.None

    contextDrawer: Kirigami.ContextDrawer {
        id: contextDrawer
    }

    Component.onCompleted: {
        if (startModule.length > 0) {
            module.name = startModule
            var container = kcmContainer.createObject(pageStack, {"kcm": module.kcm, "internalPage": module.kcm.mainUi});
            pageStack.push(container);
        }
        if (modulesList.visible) {
            modulesList.forceActiveFocus();
            pageStack.KeyNavigation.up = modulesList
        }
    }

    Connections {
        target: settingsApp
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

    header: ModulesList {
        id: modulesList
        visible: !singleModule
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
