/*
    SPDX-FileCopyrightText: 2022 Aditya Mehra <aix.m@outlook.com>
    SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import QtQuick.Controls
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami
import org.kde.bigscreen as Bigscreen

AbstractDelegate {
    id: delegate

    implicitWidth: listView.cellWidth
    implicitHeight: listView.height

    property var iconImage
    property string comment
    property bool useIconColors: true
    property bool compactMode: false
    property bool hasComment: comment.length > 5

    Kirigami.Theme.inherit: !imagePalette.useColors
    Kirigami.Theme.textColor: imagePalette.textColor
    Kirigami.Theme.backgroundColor: imagePalette.backgroundColor
    Kirigami.Theme.highlightColor: Kirigami.Theme.accentColor

    Kirigami.ImageColors {
        id: imagePalette
        property bool useColors: useIconColors
        property color backgroundColor: useColors ? dominantContrast : Kirigami.Theme.backgroundColor
        property color accentColor: useColors ? highlight : Kirigami.Theme.highlightColor
        property color textColor: useColors ? (Kirigami.ColorUtils.brightnessForColor(dominantContrast) === Kirigami.ColorUtils.Light ? imagePalette.closestToBlack : imagePalette.closestToWhite) : Kirigami.Theme.textColor
    }

    contentItem: Item {
        id: content

        GridLayout {
            id: topArea
            width: parent.width
            height: parent.height * 0.75
            anchors.top: parent.top
            columns: 2

            Behavior on columns {
                PauseAnimation {
                    duration: Kirigami.Units.longDuration / 2
                }
            }

            Kirigami.Icon {
                id: iconItem
                Layout.preferredWidth: topArea.columns > 1 ? parent.height * 0.75 : (delegate.compactMode ? parent.height / 2 : parent.height)
                Layout.preferredHeight: width
                source: delegate.iconImage || delegate.icon.name
                property var pathRegex: /^(\/[^\/]+)+$/;
                onStatusChanged:{
                    if (status === 1) {
                        if (pathRegex.test(source)) {
                            console.log("Snaps/Flatpak icon color not supported.");
                        } else {
                            imagePalette.source = iconItem.source;
                            imagePalette.update();
                        }
                    }
                }

                Behavior on Layout.preferredWidth {
                    ParallelAnimation {
                        NumberAnimation {
                            duration: Kirigami.Units.longDuration / 2
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
                    renderType: Text.NativeRendering
                    width: parent.width
                    height: parent.height
                    wrapMode: Text.WordWrap
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: delegate.compactMode ? width * 0.2 : width * 0.1
                    font.weight: Font.ExtraBold
                    maximumLineCount: 2
                    elide: Text.ElideRight
                    text: delegate.text
                    color: Kirigami.Theme.textColor
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
            height: parent.height * 0.25
            font.pixelSize: height * 0.15
            maximumLineCount: 3
            elide: Text.ElideRight
            wrapMode: Text.WordWrap
            text: delegate.comment
            color: Kirigami.Theme.textColor

            Behavior on opacity {
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
                implicitWidth: delegate.compactMode ? listView.cellWidth + (listView.cellWidth / 1.25) : listView.cellWidth
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
                implicitWidth: delegate.compactMode ? listView.cellWidth + (listView.cellWidth / 1.25) : listView.cellWidth
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
