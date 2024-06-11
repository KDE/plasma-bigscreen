/*
   Copyright (c) 2016 David Rosca <nowrep@gmail.com>

   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Library General Public
   License version 2 as published by the Free Software Foundation.

   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.

   You should have received a copy of the GNU Library General Public License
   along with this library; see the file COPYING.LIB.  If not, write to
   the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
   Boston, MA 02110-1301, USA.
*/
import QtQuick 2.4
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.1
import org.kde.kirigami as Kirigami
import org.kde.ksvg as KSvg

Item {
    id: root
    property string themeName
    property var themeBackgroundColor
    property var themeTextColor
    property var themeHighlightColor
    Kirigami.Theme.colorSet: Kirigami.Theme.Window

    Item {
        id: backgroundMask
        anchors.fill: parent
        clip: true

        KSvg.FrameSvgItem {
            id: background
            // Normalize margins around background.
            // Some themes like "Air" have huge transparent margins which would result in too small container area.
            // Sadly all of the breathing, shadow and border sizes are in one single margin value,
            // but for typical themes the border is the smaller part the margin and should be in the size of
            // Units.largeSpacing, to which we add another Units.largeSpacing for margin of the visual content
            // Ideally Plasma::FrameSvg exposes the transparent margins one day.
            readonly property int generalMargin: 2 * Kirigami.Units.largeSpacing
            anchors {
                fill: parent
                topMargin: -margins.top + generalMargin
                bottomMargin: -margins.bottom + generalMargin
                leftMargin: -margins.left + generalMargin
                rightMargin: -margins.right + generalMargin
            }
            imagePath: "widgets/background"
        }
    }

    Item {
        id: contents
        anchors {
            fill: parent
            topMargin: background.generalMargin
            bottomMargin: background.generalMargin
            leftMargin: background.generalMargin
            rightMargin: background.generalMargin
        }

        Clock {
            id: clock
            bgColor: themeBackgroundColor
            textColor: themeTextColor
            highlightColor: themeHighlightColor
        }        
    }

    Component.onCompleted: {
        kcm.applyPlasmaTheme(root, themeName);
    }
}
