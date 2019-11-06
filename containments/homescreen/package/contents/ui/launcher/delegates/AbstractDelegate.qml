/*
 *  Copyright 2019 Aditya Mehra <aix.m@outlook.com>
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

import QtQuick 2.9
import QtQuick.Layouts 1.3

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kirigami 2.11 as Kirigami

PlasmaComponents.ItemDelegate {
    id: delegate

    implicitWidth: listView.cellWidth
    implicitHeight: listView.height

    readonly property ListView listView: ListView.view

    onClicked: {
        listView.forceActiveFocus()
        console.log(index)
        listView.currentIndex = index
        console.log(listView.currentIndex)
    }

    leftPadding: frame.margins.left + background.extraMargin
    topPadding: frame.margins.top + background.extraMargin
    rightPadding: frame.margins.right + background.extraMargin
    bottomPadding: frame.margins.bottom + background.extraMargin

    Keys.onReturnPressed: {
        clicked();
    }

    background: Item {
        id: background
        property real extraMargin: listView.currentIndex == index && delegate.activeFocus ? 0 : units.gridUnit/2
        Behavior on extraMargin {
            NumberAnimation {
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InOutQuad
            }
        }

        ShaderEffect {
            id: shader
            anchors.fill: frame
            property variant source: ShaderEffectSource {
                width: frame.width
                height: frame.height
                sourceItem: root.wallpaper
                sourceRect: Qt.rect(shader.Kirigami.ScenePosition.x, shader.Kirigami.ScenePosition.y, shader.width, shader.height)
            }
            property real xUnit: -1/width
            property real yUnit: -1/height
            property real radius: 32

            property real contrast: 0.5
            property real saturation: 1.3
            property real intensity: theme.backgroundColor.hslLightness > 0.5 ? 1.8 : 0.8

            readonly property real transl: (1.0 - contrast) / 2.0;
            readonly property real rval: (1.0 - saturation) * 0.2126;
            readonly property real gval: (1.0 - saturation) * 0.7152;
            readonly property real bval: (1.0 - saturation) * 0.0722;
            property var colorMatrix: Qt.matrix4x4(
                    contrast, 0,        0,        0.0,
                    0,        contrast, 0,        0.0,
                    0,        0,        contrast, 0.0,
                    transl,   transl,   transl,   1.0).times(Qt.matrix4x4(
                        rval + saturation, rval,     rval,     0.0,
                        gval,     gval + saturation, gval,     0.0,
                        bval,     bval,     bval + saturation, 0.0,
                        0,        0,        0,        1.0)).times(Qt.matrix4x4(
                            intensity, 0,         0,         0,
                            0,         intensity, 0,         0,
                            0,         0,         intensity, 0,
                            0,         0,         0,         1
                ));

           
            fragmentShader: "
                uniform mediump sampler2D source;
                uniform lowp float qt_Opacity;
                uniform highp float xUnit;
                uniform highp float yUnit;
                uniform lowp float radius;
                uniform mediump mat4 colorMatrix;

                varying mediump vec2 qt_TexCoord0;
                void main() {

                    gl_FragColor = texture2D(source, qt_TexCoord0)  * colorMatrix ;//* qt_Opacity;
                }"

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
            
            width: listView.currentIndex == index && delegate.activeFocus ? parent.width : parent.width - units.gridUnit
            height: listView.currentIndex == index && delegate.activeFocus ? parent.height : parent.height - units.gridUnit
            opacity: 0.8
        }
    }
    
    contentItem: ColumnLayout {
        spacing: 0
        Kirigami.Icon {
            id: icon
            Layout.fillWidth: true
            Layout.fillHeight: true
            source: delegate.icon.name || delegate.icon.source
        }

        PlasmaComponents.Label {
            id: label
            visible: text.length > 0
    
            Layout.fillWidth: true
            Layout.preferredHeight: root.reservedSpaceForLabel
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            maximumLineCount: 2
            elide: Text.ElideRight
            color: PlasmaCore.ColorScope.textColor

            text: delegate.text
        }
    }
}
