/*
    SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2019 Aditya Mehra <aix.m@outlook.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15 as Controls
import org.kde.kirigami 2.19 as Kirigami

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
        ColumnLayout {
            Controls.CheckBox {
                id: backgroundCheckbox
                text: i18n("Use Colored Tiles")
                checked: plasmoid.configuration.coloredTiles
                onCheckedChanged: plasmoid.configuration.coloredTiles = checked
                focus: true
                Keys.onEnterPressed: (event)=> {
                    checked = !checked
                }
                Keys.onReturnPressed: (event)=> {
                    checked = !checked
                }
                KeyNavigation.down: expandingCheckbox
            }
            Controls.CheckBox {
                id: expandingCheckbox
                text: i18n("Use Expanding Tiles")
                checked: plasmoid.configuration.expandingTiles
                onCheckedChanged: plasmoid.configuration.expandingTiles = checked
                Keys.onEnterPressed: (event)=> {
                    checked = !checked
                }
                Keys.onReturnPressed: (event)=> {
                    checked = !checked
                }
                KeyNavigation.down: closeButton
            }
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
        onClicked: (mouse)=> {
            window.close()
        }
        Keys.onEnterPressed: (event)=> {
            clicked()
        }
        Keys.onReturnPressed: (event)=> {
            clicked()
        }
        KeyNavigation.up: backgroundCheckbox
    }
}
