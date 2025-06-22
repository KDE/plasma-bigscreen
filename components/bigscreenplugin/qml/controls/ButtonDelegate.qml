// SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import QtQuick.Effects

import org.kde.kirigami as Kirigami

ItemDelegate {
    id: root

    /*!
       \brief A label containing secondary text that appears under the
       inherited text property.

       This provides additional information shown in a faint gray color.
       \default ""
     */
    property string description: ""

    /*!
       \qmlproperty Label descriptionItem
       \brief This property allows for access to the description label item.
     */
    property alias descriptionItem: internalDescriptionItem

    /*!
       \brief This property specifies whether the description font should be smaller
     */
    property bool smallDescription: true

    /*!
       \qmlproperty Label textItem
       \brief This property holds allows for access to the text label item.
     */
    property alias textItem: internalTextItem

    /*!
       \brief This property holds an item that will be displayed before
       the delegate's contents.
       \default null
     */
    property var leading: null

    /*!
       \brief This property holds the padding after the leading item.
       \default Kirigami.Units.smallSpacing
     */
    property real leadingPadding: Kirigami.Units.gridUnit

    /*!
       \brief This property holds an item that will be displayed after
       the delegate's contents.
       \default null
     */
    property var trailing: null

    /*!
       \brief This property holds the padding before the trailing item.
       \default Kirigami.Units.smallSpacing
     */
    property real trailingPadding: Kirigami.Units.gridUnit

    onPressed: root.forceActiveFocus()
    Keys.onReturnPressed: {
        clicked();
    }

    contentItem: RowLayout {
        spacing: 0

        QQC2.Control {
            Layout.rightMargin: visible ? root.leadingPadding : 0
            visible: root.leading
            implicitHeight: visible ? root.leading.implicitHeight : 0
            implicitWidth: visible ? root.leading.implicitWidth : 0
            contentItem: root.leading
        }

        Kirigami.Icon {
            Layout.rightMargin: Kirigami.Units.gridUnit
            Layout.alignment: Qt.AlignVCenter

            color: root.icon.color
            implicitHeight: (root.icon.name !== "") ? root.icon.height : 0
            implicitWidth: (root.icon.name !== "") ? root.icon.width : 0
            source: root.icon.name
            visible: root.icon.name != ''
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: (!internalTextItem.visible || !internalDescriptionItem.visible) ? 0 : Kirigami.Units.smallSpacing

            QQC2.Label {
                id: internalTextItem
                Layout.fillWidth: true
                text: root.text
                font.pixelSize: Units.defaultFontPixelSize
                elide: Text.ElideRight
                visible: root.text
                Accessible.ignored: true // base class sets this text on root already
            }
            QQC2.Label {
                id: internalDescriptionItem
                Layout.fillWidth: true
                text: root.description
                font.pixelSize: root.smallDescription ? 14 : Units.defaultFontPixelSize
                color: Kirigami.Theme.disabledTextColor
                visible: root.description !== ''
                elide: Text.ElideRight
                wrapMode: Text.Wrap
            }
        }

        QQC2.Control {
            Layout.leftMargin: visible ? root.trailingPadding : 0
            visible: root.trailing
            implicitHeight: visible ? root.trailing.implicitHeight : 0
            implicitWidth: visible ? root.trailing.implicitWidth : 0
            contentItem: root.trailing
        }
    }
}