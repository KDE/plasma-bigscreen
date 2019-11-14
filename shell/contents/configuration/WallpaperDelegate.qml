/*
 *  Copyright 2019 Marco Martin <mart@kde.org>
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

import QtQuick 2.12
import QtQuick.Layouts 1.0
import QtQuick.Controls 2.3 as Controls
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.configuration 2.0

//for the "simple mode"
import org.kde.plasma.wallpapers.image 2.0 as Wallpaper
import org.kde.kquickcontrolsaddons 2.0 as Addons
import org.kde.kcm 1.1 as KCM
import org.kde.kirigami 2.11 as Kirigami

Controls.ItemDelegate {
    id: delegate
    width: wallpapersView.cellWidth
    height: wallpapersView.cellHeight

    leftPadding: frame.margins.left + background.extraMargin
    topPadding: frame.margins.top + background.extraMargin
    rightPadding: frame.margins.right + background.extraMargin
    bottomPadding: frame.margins.bottom + background.extraMargin

    property bool highlight: wallpapersView.currentIndex === index

    z: highlight ? 2 : 0

    background: Item {
        id: background
        property real extraMargin:  Math.round(delegate.highlight ? -units.gridUnit/2 : units.gridUnit/2)
        Behavior on extraMargin {
            NumberAnimation {
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InOutQuad
            }
        }

        PlasmaCore.FrameSvgItem {
            anchors {
                fill: frame
                leftMargin: -margins.left
                topMargin: -margins.top
                rightMargin: -margins.right
                bottomMargin: -margins.bottom
            }
            imagePath: Qt.resolvedUrl("./background.svg")
            prefix: "shadow"
        }
        PlasmaCore.FrameSvgItem {
            id: frame
            anchors {
                fill: parent
                margins: background.extraMargin
            }
            imagePath: Qt.resolvedUrl("./background.svg")
            
            width: delegate.highlight && delegate.activeFocus ? parent.width : parent.width - units.gridUnit
            height: delegate.highlight && delegate.activeFocus ? parent.height : parent.height - units.gridUnit
            opacity: 0.8
        }
    }
}
