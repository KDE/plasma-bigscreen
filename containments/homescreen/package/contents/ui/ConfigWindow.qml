/*
 * Copyright 2019 Marco Martin <mart@kde.org>
 * Copyright 2019 Aditya Mehra <aix.m@outlook.com>
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
import QtQuick.Window 2.3
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2 as Controls
import org.kde.kirigami 2.11 as Kirigami
import Mycroft 1.0 as Mycroft

Window {
    id: window
    color: Qt.rgba(0, 0, 0, 0.8)

    width: screen.availableGeometry.width
    height: screen.availableGeometry.height

    Kirigami.Theme.colorSet: Kirigami.Theme.Complementary
    Item {
        id: contentItem
        anchors {
            fill: parent
            margins: Kirigami.Units.largeSpacing
        }
        Controls.CheckBox {
            id: backgroundCheckbox
            z: 999
            text: i18n("Use Colored Tiles")
            checked: plasmoid.configuration.coloredTiles
            onCheckedChanged: plasmoid.configuration.coloredTiles = checked
            focus: true
            Keys.onEnterPressed: checked = !checked
            Keys.onReturnPressed: checked = !checked
            KeyNavigation.down: closeButton
        }
    }
    Controls.Button {
        id: closeButton
        anchors {
            bottom: parent.bottom
            right: parent.right
        }
        icon.name: "window-close"
        text: i18n("close")
        onClicked: window.close()
        Keys.onEnterPressed: clicked()
        Keys.onReturnPressed: clicked()
        KeyNavigation.up: backgroundCheckbox
    }
}
