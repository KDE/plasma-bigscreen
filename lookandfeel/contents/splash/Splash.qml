/*
    SPDX-FileCopyrightText: 2021 Aditya Mehra <aix.m@outlook.com>
    SPDX-FileCopyrightText: 2014 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.5
import QtQuick.Layouts 1.3
import QtQuick.Window 2.2
import org.kde.mycroft.bigscreen 1.0 as BigScreen

Rectangle {
    id: root
    color: "black"
    anchors.fill: parent
    property int stage
    property var envReader: BigScreen.EnvReader

    // Workaround For Devices Where We Don't Support 4K Scaling
    // Using PLASMA_USE_QT_SCALING with QT_SCREEN_SCALE_FACTORS causes a bug where parent screen geometry does not change when applying 1980x1800 resolution via Kscreen-Doctor
    function disableScale(){
        if(envReader.getValue("PLASMA_USE_QT_SCALING") == "true" && envReader.getValue("BIGSCREEN_HARDWARE_PLATFORM") == "RPI4" && root.width > 1920) {
            content.width = root.width / 2
            content.height = root.height / 2
            content.visible = true
        }
    }

    Connections {
        target: BigScreen.EnvReader
        onConfigChangeReceived: {
            disableScale();
        }
    }

    onStageChanged: {
        if (stage == 2) {
            introAnimation.running = true;
        } else if (stage == 5) {
            introAnimation.target = busyIndicator;
            introAnimation.from = 1;
            introAnimation.to = 0;
            introAnimation.running = true;
        }
    }

    Item {
        id: content
        width: parent.width
        height: parent.height
        opacity: 0

        TextMetrics {
            id: units
            text: "M"
            property int gridUnit: boundingRect.height
            property int largeSpacing: units.gridUnit
            property int smallSpacing: Math.max(2, gridUnit/4)
        }

        ColumnLayout {
            id: rootCol
            anchors.centerIn: parent
            width: parent.width

            Text {
                id: welcomeMessage
                renderType: Screen.devicePixelRatio % 1 !== 0 ? Text.QtRendering : Text.NativeRendering
                text: i18n("Welcome")
                color: "white"
                font.pointSize: 34
                font.weight: Font.Normal
                font.family: "oxygen"
                Layout.alignment: Qt.AlignHCenter
            }

            Image {
                id: busyIndicator
                Layout.alignment: Qt.AlignHCenter
                source: "images/busycolored.svg"
                sourceSize.height: units.gridUnit * 2
                sourceSize.width: units.gridUnit * 2
                RotationAnimator on rotation {
                    id: rotationAnimator
                    from: 0
                    to: 360
                    duration: 1500
                    loops: Animation.Infinite
                }
            }

            Image {
                id: logo
                Layout.alignment: Qt.AlignHCenter
                property real size: units.gridUnit * 5
                source: "images/logo-big.svg"
                sourceSize.width: size + units.gridUnit * 12
                sourceSize.height: size
            }
        }

        Row {
            spacing: units.smallSpacing*2
            anchors {
                bottom: parent.bottom
                right: parent.right
                margins: units.gridUnit
            }
            Text {
                color: "#eff0f1"
                // Work around Qt bug where NativeRendering breaks for non-integer scale factors
                // https://bugreports.qt.io/browse/QTBUG-67007
                renderType: Screen.devicePixelRatio % 1 !== 0 ? Text.QtRendering : Text.NativeRendering
                anchors.verticalCenter: parent.verticalCenter
                text: i18ndc("plasma_lookandfeel_org.kde.lookandfeel", "This is the first text the user sees while starting in the splash screen, should be translated as something short, is a form that can be seen on a product. Plasma is the project name so shouldn't be translated.", "Plasma made by KDE")
            }
            Image {
                source: "images/kde.svgz"
                sourceSize.height: units.gridUnit * 2
                sourceSize.width: units.gridUnit * 2
            }
        }
    }

    OpacityAnimator {
        id: introAnimation
        running: false
        target: content
        from: 0
        to: 1
        duration: 1000
        easing.type: Easing.InOutQuad
    }
}
