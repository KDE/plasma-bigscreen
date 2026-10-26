/*
    SPDX-FileCopyrightText: 2022 Aditya Mehra <aix.m@outlook.com>
    SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import QtQuick.Controls as QQC2
import QtQuick.Window
import org.kde.kirigami as Kirigami

QQC2.ItemDelegate {
    id: delegate

    signal longClick

    readonly property Flickable listView: {
        var candidate = parent;
        while (candidate) {
            if (candidate instanceof Flickable) {
                return candidate;
            }
            candidate = candidate.parent;
        }
        return null;
    }

    // The row in the view, or -1 when the card isn't a view delegate (such as a trailing card)
    readonly property int modelIndex: typeof index !== "undefined" ? index : -1

    property bool forceCurrent: false // force "current" visual state
    readonly property bool isCurrent: (listView && modelIndex >= 0 && listView.currentIndex == modelIndex && activeFocus) || forceCurrent

    // Raised above the row, for moving a favorite
    property bool lifted: false

    // TODO: Wide artwork to fill the card with instead of the icon
    property string artwork

    z: isCurrent ? 2 : 0

    property var iconImage
    property bool useIconColors: true

    property string subtitle

    // Whether the application has an open window
    property bool running: false

    readonly property real cardWidth: listView ? (listView.cardWidth ?? listView.cellWidth - Kirigami.Units.gridUnit) : 0
    readonly property real cardHeight: listView ? (listView.cardHeight ?? cardWidth * 0.625) : 0

    readonly property int longPressDuration: Qt.styleHints.mousePressAndHoldInterval

    // TODO: use to tint background?
    readonly property color tileColor: imagePalette.useColors ? imagePalette.dominant : Kirigami.Theme.highlightColor

    implicitWidth: listView ? listView.cellWidth : 0
    implicitHeight: listView ? listView.cellHeight : 0
    hoverEnabled: true

    onClicked: {
        if (listView && modelIndex >= 0) {
            listView.forceActiveFocus();
            listView.currentIndex = modelIndex;
        }
    }

    leftPadding: 0
    rightPadding: 0
    topPadding: 0
    bottomPadding: 0
    leftInset: 0
    rightInset: 0
    topInset: 0
    bottomInset: 0

    Kirigami.Theme.inherit: false
    Kirigami.Theme.colorSet: Kirigami.Theme.Complementary

    Kirigami.ImageColors {
        id: imagePalette
        readonly property bool useColors: delegate.useIconColors && imagePalette.dominant.a > 0
    }

    property real pressedFactor: 0
    property bool keyPressed: false
    readonly property bool appPressed: pressed || keyPressed
    onAppPressedChanged: {
        if (appPressed){
            pressedAnim.restart();
        } else{
            pressedAnim.stop();
            pressedFactor = 0;
        }
    }

    function resetPress() {
        pressedAnim.stop();
        pressedFactor = 0;
    }

    onPressAndHold: {
        resetPress();
        delegate.longClick();
    }

    NumberAnimation on pressedFactor {
        id: pressedAnim
        from: 0
        to: 1
        running: false
        duration: delegate.longPressDuration
        onFinished: {
            if (delegate.keyPressed) {
                delegate.keyPressed = false;
                delegate.resetPress();
                delegate.longClick();
            }
        }
    }

    Keys.onPressed: (event) => {
        if (event.isAutoRepeat){
            return;
        }
        if (event.key == Qt.Key_Return){
            event.accepted = true;
            keyPressed = true;
        } else{
            event.accepted = false;
        }
    }
    Keys.onReleased: (event) => {
        if (event.isAutoRepeat){
            return;
        }
        if (keyPressed && event.key == Qt.Key_Return){
            event.accepted = true;
            keyPressed = false;
            click();
        } else{
            event.accepted = false;
        }
    }

    background: null

    contentItem: Item {
        id: content

        // Background of card
        Kirigami.ShadowedImage {
            id: card
            x: Math.round((delegate.width - width) / 2)
            width: delegate.cardWidth
            height: delegate.cardHeight

            radius: Kirigami.Units.cornerRadius * 2

            source: delegate.artwork.length > 0 ? "file://" + delegate.artwork : ""
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            sourceSize.width: width * Screen.devicePixelRatio
            sourceSize.height: height * Screen.devicePixelRatio

            color: {
                const base = Kirigami.Theme.backgroundColor;
                if (!imagePalette.useColors) {
                    return delegate.isCurrent ? Qt.lighter(base, 1.3) : base;
                }
                return Kirigami.ColorUtils.tintWithAlpha(base, imagePalette.dominant, delegate.isCurrent ? 0.85 : 0.3);
            }
            Behavior on color { ColorAnimation { duration: Kirigami.Units.longDuration } }

            border.width: delegate.isCurrent ? 4 : 0
            border.color: Kirigami.Theme.highlightColor

            shadow.size: delegate.lifted ? Kirigami.Units.gridUnit * 2.5 : (delegate.isCurrent ? Kirigami.Units.gridUnit * 1.5 : Kirigami.Units.largeSpacing)
            shadow.yOffset: delegate.lifted ? Kirigami.Units.gridUnit : (delegate.isCurrent ? Kirigami.Units.smallSpacing * 2 : Kirigami.Units.smallSpacing)
            shadow.color: Qt.rgba(0, 0, 0, 0.5)

            scale: delegate.lifted ? 1.1 : (delegate.isCurrent ? 1.06 : 1.0)
            Behavior on scale { NumberAnimation { duration: Kirigami.Units.longDuration; easing.type: Easing.OutCubic } }

            transform: Translate {
                y: delegate.lifted ? -Kirigami.Units.gridUnit : 0
                Behavior on y { NumberAnimation { duration: Kirigami.Units.longDuration; easing.type: Easing.OutCubic } }
            }

            Kirigami.Icon {
                id: iconItem
                visible: card.status !== Image.Ready
                anchors.centerIn: parent
                width: Math.round(parent.height * 0.58)
                height: width
                source: delegate.iconImage || delegate.icon.name

                onStatusChanged: {
                    if (status === Kirigami.Icon.Ready) {
                        imagePalette.source = iconItem.source;
                    }
                }
            }

            // Long press animation
            Shape {
                id: holdIndicator
                anchors {
                    top: parent.top
                    right: parent.right
                    margins: Kirigami.Units.largeSpacing
                }
                width: Kirigami.Units.iconSizes.medium
                height: width
                // Only shown for the second half of the hold, so quick clicks don't flash it
                readonly property real progress: Math.max(0, delegate.pressedFactor - 0.5) * 2
                visible: progress > 0
                preferredRendererType: Shape.CurveRenderer

                ShapePath {
                    strokeColor: Qt.rgba(0, 0, 0, 0.4)
                    strokeWidth: 4
                    fillColor: "transparent"
                    PathAngleArc {
                        centerX: holdIndicator.width / 2
                        centerY: holdIndicator.height / 2
                        radiusX: holdIndicator.width / 2 - 2
                        radiusY: radiusX
                        startAngle: 0
                        sweepAngle: 360
                    }
                }
                ShapePath {
                    strokeColor: Kirigami.Theme.highlightColor
                    strokeWidth: 4
                    fillColor: "transparent"
                    capStyle: ShapePath.RoundCap
                    PathAngleArc {
                        centerX: holdIndicator.width / 2
                        centerY: holdIndicator.height / 2
                        radiusX: holdIndicator.width / 2 - 2
                        radiusY: radiusX
                        startAngle: -90
                        sweepAngle: 360 * holdIndicator.progress
                    }
                }
            }
        }

        ColumnLayout {
            id: labels
            property real focusOffset: delegate.isCurrent ? Kirigami.Units.smallSpacing * 2 : 0
            Behavior on focusOffset { NumberAnimation { duration: Kirigami.Units.longDuration; easing.type: Easing.OutCubic } }

            x: card.x
            y: card.height + Kirigami.Units.largeSpacing + focusOffset
            width: card.width
            spacing: 0

            QQC2.Label {
                Layout.fillWidth: true
                text: delegate.text
                color: Kirigami.Theme.textColor
                font.pixelSize: 18
                elide: Text.ElideRight
                maximumLineCount: 1
            }
            QQC2.Label {
                Layout.fillWidth: true
                visible: text.length > 0
                text: delegate.running ? i18n("Running") : delegate.subtitle
                color: Kirigami.Theme.disabledTextColor
                font.pixelSize: 14
                elide: Text.ElideRight
                maximumLineCount: 1
            }
        }
    }
}
