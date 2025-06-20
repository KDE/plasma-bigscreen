// SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later OR LicenseRef-KDE-Accepted-GPL

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import QtQuick.Effects

import org.kde.kirigami as Kirigami

OverlayWindow {
    id: root

    property string title
    property alias header: headerControl.contentItem
    property alias contentItem: contentControl.contentItem
    property alias footer: footerControl.contentItem

    property real topPadding: Kirigami.Units.gridUnit + Kirigami.Units.largeSpacing
    property real bottomPadding: Kirigami.Units.gridUnit + Kirigami.Units.largeSpacing
    property real leftPadding: Kirigami.Units.gridUnit + Kirigami.Units.largeSpacing
    property real rightPadding: Kirigami.Units.gridUnit + Kirigami.Units.largeSpacing

    signal accepted()
    signal rejected()

    onRejected: root.hideOverlay()

    function open() {
        root.showOverlay();
    }

    content: Item {
        MouseArea {
            anchors.fill: parent
            onClicked: root.hideOverlay()
        }

        QQC2.Control {
            id: frame
            anchors.centerIn: parent
            width: Math.min(parent.width * 0.7, Math.max(parent.width * 0.4, Kirigami.Units.gridUnit * 35))

            Kirigami.Theme.inherit: false
            Kirigami.Theme.colorSet: Kirigami.Theme.Window

            background: MouseArea {
                Rectangle {
                    anchors.fill: parent
                    color: Kirigami.Theme.backgroundColor
                    radius: Kirigami.Units.largeSpacing
                }
            }

            contentItem: ColumnLayout {
                QQC2.Control {
                    id: headerControl
                    Layout.fillWidth: true
                    topPadding: Kirigami.Units.gridUnit
                    bottomPadding: Kirigami.Units.gridUnit
                    leftPadding: Kirigami.Units.gridUnit
                    rightPadding: Kirigami.Units.gridUnit

                    contentItem: Kirigami.Heading {
                        text: root.title
                        font.pixelSize: 28
                        font.weight: Font.Light
                    }
                }

                QQC2.Control {
                    id: contentControl
                    topPadding: root.topPadding
                    bottomPadding: root.bottomPadding
                    leftPadding: root.leftPadding
                    rightPadding: root.rightPadding

                    Layout.fillWidth: true
                }

                QQC2.Control {
                    id: footerControl
                    Layout.fillWidth: true

                    background: Rectangle {
                        color: Kirigami.Theme.alternateBackgroundColor
                        bottomLeftRadius: Kirigami.Units.largeSpacing
                        bottomRightRadius: Kirigami.Units.largeSpacing
                    }

                    contentItem: QQC2.DialogButtonBox {
                        topPadding: Kirigami.Units.gridUnit
                        bottomPadding: Kirigami.Units.gridUnit
                        leftPadding: Kirigami.Units.gridUnit
                        rightPadding: Kirigami.Units.gridUnit

                        standardButtons: QQC2.DialogButtonBox.Ok | QQC2.DialogButtonBox.Cancel
                        onAccepted: root.accepted()
                        onRejected: root.rejected()
                    }
                }
            }
        }

        MultiEffect {
            id: frameShadow

            anchors.fill: frame
            source: frame
            blurMax: 16
            shadowEnabled: true
            shadowOpacity: 0.6
            shadowColor: 'black'
        }
    }
}