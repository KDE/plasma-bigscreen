/*
 *  Copyright 2019 Marco Martin <mart@kde.org>
*   Copyright 2012 by Sebastian Kügler <sebas@kde.org>
*
*   This program is free software; you can redistribute it and/or modify
*   it under the terms of the GNU Library General Public License as
*   published by the Free Software Foundation; either version 2, or
*   (at your option) any later version.
*
*   This program is distributed in the hope that it will be useful,
*   but WITHOUT ANY WARRANTY; without even the implied warranty of
*   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*   GNU Library General Public License for more details
*
*   You should have received a copy of the GNU Library General Public
*   License along with this program; if not, write to the
*   Free Software Foundation, Inc.,
*   51 Franklin Street, Fifth Floor, Boston, MA  2.010-1301, USA.
*/

import QtQuick 2.0
import QtQuick.Controls 2.0 as QQC2
import org.kde.kirigami 2.4
import QtGraphicalEffects 1.12


QQC2.Label {
    id: heading

    /**
     * level: int
     * The level determines how big the section header is display, values
     * between 1 (big) and 5 (small) are accepted
     */
    property int level: 1

    /**
     * step: int
     * adjust the point size in between a level and another.
     * DEPRECATED
     */
    property int step: 0

    font.pointSize: headerPointSize(level)

    function headerPointSize(l) {
        var n = Theme.defaultFont.pointSize;
        var s;
        switch (l) {
        case 1:
            return Math.round(n * 1.80) + step;
        case 2:
            return Math.round(n * 1.30) + step;
        case 3:
            return Math.round(n * 1.20) + step;
        case 4:
            return Math.round(n * 1.10) + step;
        default:
            return n + step;
        }
    }
    layer.enabled: true
    layer.effect: DropShadow {
        anchors.fill: parent
        horizontalOffset: 0
        verticalOffset: 2
        radius: 8.0
        samples: 17
        color: Qt.rgba(0,0,0,0.6)
        source: appslabel
    }
}
