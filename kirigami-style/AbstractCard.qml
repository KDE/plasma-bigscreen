/*
 *   Copyright 2018 Marco Martin <mart@kde.org>
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
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 2.6
import QtGraphicalEffects 1.0
import org.kde.kirigami 2.11 as Kirigami
import org.kde.plasma.core 2.0 as PlasmaCore
import "templates" as T

T.AbstractCard {
    id: root

    leftPadding: frame.margins.left
    topPadding: frame.margins.top
    rightPadding: frame.margins.right
    bottomPadding: frame.margins.bottom

    Keys.onReturnPressed: {
        clicked();
    }
Component.onCompleted: {
    background.startupCompleted= true
}
    background: Item {
        id: background
        property bool startupCompleted: false
        property real extraMargin: startupCompleted ? Math.round(root.checked && root.activeFocus ? -Kirigami.Units.gridUnit/2 : Kirigami.Units.gridUnit/2) : 0
        // FIXME: assumption of abstractcard internal structure
        property Item _mainLayout: root.children[0]

        Binding {
            target: background._mainLayout.anchors
            property: "leftMargin"
            value: background.extraMargin
        }
        Binding {
            target: background._mainLayout.anchors
            property: "topMargin"
            value: background.extraMargin
        }
        Binding {
            target: background._mainLayout.anchors
            property: "rightMargin"
            value: background.extraMargin
        }
        Binding {
            target: background._mainLayout.anchors
            property: "bottomMargin"
            value: background.extraMargin
        }
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
            
            width: root.checked && delegate.activeFocus ? parent.width : parent.width - Kirigami.Units.gridUnit
            height: root.checked && delegate.activeFocus ? parent.height : parent.height - Kirigami.Units.gridUnit
            opacity: 0.8
        }
    }
}
