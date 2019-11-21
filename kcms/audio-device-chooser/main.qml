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

import QtQuick 2.9
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.10 as Kirigami
import QtQuick.Controls 2.12
import org.kde.plasma.core 2.1 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.private.volume 0.1
import QtQuick.Window 2.2

import "delegates" as Delegates
import "views" as Views

Window {
    id: root
    title: "Audio Device Chooser"
    visibility: "Maximized"
    color: Qt.rgba(0, 0, 0, 0.4)
    signal activateDeviceView

    Component.onCompleted: {
        root.activateDeviceView
    }

    DeviceChooserPage{}
}

