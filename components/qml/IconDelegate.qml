/*
    SPDX-FileCopyrightText: 2022 Aditya Mehra <aix.m@outlook.com>
    SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.14
import QtQuick.Layouts 1.14
import QtGraphicalEffects 1.14
import QtQuick.Controls 2.14
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kirigami 2.13 as Kirigami
import org.kde.mycroft.bigscreen 1.0 as BigScreen

AbstractDelegate {
    id: delegate

    implicitWidth: listView.cellWidth
    implicitHeight: listView.height

    property var iconImage
    property string comment
    property bool useIconColors: true
    property bool compactMode: false
    property bool hasComment: commentLabel.text.length > 5 ? 1 : 0

    Kirigami.Theme.inherit: !imagePalette.useColors
    Kirigami.Theme.textColor: imagePalette.textColor
    Kirigami.Theme.backgroundColor: imagePalette.backgroundColor
    Kirigami.Theme.highlightColor: imagePalette.accentColor

    Kirigami.ImageColors {
        id: imagePalette
        source: iconItem.source
        property bool useColors: useIconColors
        property color backgroundColor: useColors ? dominantContrast : PlasmaCore.ColorScope.backgroundColor
        property color accentColor: useColors ? highlight : PlasmaCore.ColorScope.highlightColor
        property color textColor: useColors
            ? (Kirigami.ColorUtils.brightnessForColor(dominantContrast) === Kirigami.ColorUtils.Light ? imagePalette.closestToBlack : imagePalette.closestToWhite)
            : PlasmaCore.ColorScope.textColor
    }

    contentItem: Item {
        id: content

        GridLayout {
            id: topArea
            width:  parent.width
            height: parent.height * 0.25
            anchors.top: parent.top
            columns: 2

            Behavior on columns {
                PauseAnimation {
                    duration: Kirigami.Units.longDuration / 2
                }
            }

            PlasmaCore.IconItem {
                id: iconItem
                Layout.preferredWidth: topArea.columns > 1 ? parent.height * 0.75 : (delegate.compactMode ? parent.height / 2 : parent.height)
                Layout.preferredHeight: width
                source: delegate.iconImage || delegate.icon.name || delegate.icon.source ? delegate.iconImage || delegate.icon.name || delegate.icon.source : "application-x-executable"

                Behavior on Layout.preferredWidth {
                    ParallelAnimation {
                        NumberAnimation {
                            duration: Kirigami.Units.longDuration / 2;
                            easing.type: Easing.InOutQuad
                        }
                        NumberAnimation {
                            target: textLabel
                            from: 0
                            to: 1
                            properties: "opacity"
                            duration: delegate.hasComment ? Kirigami.Units.longDuration * 3 : 0
                            easing.type: Easing.InOutQuad
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "transparent"

                Label {
                    id: textLabel
                    width: parent.width
                    height: parent.height
                    wrapMode: Text.WordWrap
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: delegate.compactMode ? width * 0.2 : height * 0.9
                    font.bold: true
                    fontSizeMode: Text.Fit
                    minimumPixelSize: 2
                    maximumLineCount: 1
                    elide: Text.ElideRight
                    text: delegate.text
                    color: imagePalette.textColor
                }
            }
        }

        Label {
            id: commentLabel
            anchors.top: topArea.bottom
            anchors.bottom: parent.bottom
            anchors.topMargin: Kirigami.Units.largeSpacing
            verticalAlignment: Text.AlignTop
            width: parent.width
            height: parent.height
            font.pixelSize: height * 0.25
            maximumLineCount: 2
            elide: Text.ElideRight
            wrapMode: Text.WordWrap
            text: delegate.comment
            color: imagePalette.textColor

            Behavior on opacity  {
                NumberAnimation { duration: Kirigami.Units.longDuration * 2.5; easing.type: Easing.InOutQuad }
            }
        }
    }

    states: [
        State {
            name: "selectedNoComment"
            when: delegate.isCurrent && !hasComment

            PropertyChanges {
                target: delegate
                implicitWidth: delegate.compactMode ? listView.cellWidth + (listView.cellWidth  / 1.25) : listView.cellWidth
            }

            PropertyChanges {
                target: topArea
                height: content.height
                columns: 1
                rows: 2
            }
            PropertyChanges {
                target: iconItem
                Layout.preferredHeight: parent.height * 0.75
                Layout.preferredWidth: height
                Layout.alignment: Qt.AlignHCenter
            }
            PropertyChanges {
                target: textLabel
                horizontalAlignment: Text.AlignHCenter
            }

            PropertyChanges {
                target: commentLabel
                opacity: 0
            }
        },
        State {
            name: "selectedWithComment"
            when: delegate.isCurrent && hasComment

            PropertyChanges {
                    target: delegate
                    implicitWidth: delegate.compactMode ? listView.cellWidth + (listView.cellWidth  / 1.25) : listView.cellWidth
            }

            PropertyChanges {
                target: topArea
                height: parent.height * 0.25
                columns: 2
            }
            PropertyChanges {
                target: commentLabel
                opacity: 1
            }
        },
        State {
            name: "normal"
            when: !delegate.isCurrent

            PropertyChanges {
                target: topArea
                height: content.height
                columns: 1
                rows: 2
            }
            PropertyChanges {
                target: iconItem
                Layout.preferredHeight: delegate.compactMode ? parent.height / 2 : parent.height * 0.75
                Layout.preferredWidth: height
                Layout.alignment: Qt.AlignHCenter
            }
            PropertyChanges {
                target: textLabel
                horizontalAlignment: Text.AlignHCenter
            }

            PropertyChanges {
                target: commentLabel
                opacity: 0
            }
        }
    ]
}
