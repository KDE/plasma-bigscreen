/*
    Copyright 2019 Aditya Mehra <aix.m@outlook.com>

    This program is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public License as
    published by the Free Software Foundation; either version 2 of
    the License or (at your option) version 3 or any later version
    accepted by the membership of KDE e.V. (or its successor approved
    by the membership of KDE e.V.), which shall act as a proxy
    defined in Section 14 of version 3 of the license.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.
    
    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.14
import QtQuick.Layouts 1.14
import org.kde.kirigami 2.12 as Kirigami
import QtQuick.Controls 2.14
import org.kde.plasma.core 2.1 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.private.volume 0.1
import QtQuick.Window 2.14
import org.kde.kcm 1.1 as KCM

import "delegates" as Delegates
import "views" as Views

KCM.SimpleKCM {
    id: root
    title: i18n("Audio Device Chooser")
    
    signal activateDeviceView

    background: null
    leftPadding: Kirigami.Units.smallSpacing
    topPadding: 0
    rightPadding: Kirigami.Units.smallSpacing
    bottomPadding: 0
    
    Component.onCompleted: {
        root.activateDeviceView
    }
    
    footer: Button {
        id: kcmcloseButton
        implicitHeight: Kirigami.Units.gridUnit * 2
        anchors.left: parent.left
        anchors.right: parent.right
        
        background: Rectangle {
            color: kcmcloseButton.activeFocus ? Kirigami.Theme.highlightColor : Kirigami.Theme.backgroundColor
        }
        
        contentItem: Item {
            RowLayout {
                anchors.centerIn: parent
                Kirigami.Icon {
                    Layout.preferredWidth: Kirigami.Units.iconSizes.small
                    Layout.preferredHeight: Kirigami.Units.iconSizes.small
                    source: "window-close"
                }
                Label {
                    text: i18n("Exit")
                }
            }
        } 

        Keys.onUpPressed: root.activateDeviceView()
        
        onClicked: {
            Window.window.close()
        }
        
        Keys.onReturnPressed: {
            Window.window.close()
        }
    }

    contentItem: DeviceChooserPage {
        id: deviceChooserView
    }
}
