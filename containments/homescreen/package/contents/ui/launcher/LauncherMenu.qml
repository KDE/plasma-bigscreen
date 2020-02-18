/*
 * Copyright 2019 Aditya Mehra <aix.m@outlook.com>
 * Copyright 2015 Marco Martin <mart@kde.org>
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

import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3 as Controls
import QtQuick.Window 2.3

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.kquickcontrolsaddons 2.0
import org.kde.private.biglauncher 1.0 as Launcher
import org.kde.kirigami 2.5 as Kirigami

FocusScope {
    id: root

    readonly property int reservedSpaceForLabel: metrics.height
    signal activateAppView
    signal activateTopNavBar
    signal activateSettingsView

    property Item wallpaper: {
        for (var i in plasmoid.children) {
            if (plasmoid.children[i].toString().indexOf("WallpaperInterface") === 0) {
                return plasmoid.children[i];
            }
        }
        return null;
    }

    Component.onCompleted: {
        root.forceActiveFocus();
        plasmoid.nativeInterface.applicationListModel.loadApplications();
        plasmoid.nativeInterface.voiceAppListModel.loadApplications();
        plasmoid.nativeInterface.gamesAppListModel.loadApplications();
        root.activateAppView();
    }

    Connections {
        target: plasmoid.applicationListModel
        onAppOrderChanged: {
            root.activateAppView()
        }
    }
    
    Connections {
        target: root
        onActivateTopNavBar: {
            topButtonBar.focus = true
        }
    }

    Controls.Label {
        id: metrics
        text: "M\nM"
        visible: false
    }

    LauncherHome {}
}
