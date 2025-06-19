/*
    SPDX-FileCopyrightText: 2024 Aditya Mehra <aix.m@outlook.com>
    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami

AbstractDelegate {
    id: delegate

    property var listView: ListView.view
    implicitWidth: listView ? listView.cellWidth * 2.5 : 0
    implicitHeight: listView ? listView.height + Kirigami.Units.largeSpacing : 0

    property alias itemIcon: contentItemSvgIcon.source
    property alias itemLabel: contentItemLabel.text
    property alias itemLabelBold: contentItemLabel.font.bold
    property alias itemLabelVisible: contentItemLabel.visible
    property alias itemSubLabel: contentItemSubLabel.text
    property alias itemSubLabelVisible: contentItemSubLabel.visible
    property alias itemTickSource: contentItemTickIcon.source
    property alias itemTickOpacity: contentItemTickIcon.opacity
    property alias itemTickVisible: contentItemTickIcon.visible

    property alias itemLabelFont: contentItemLabel.font
    property alias itemSubLabelFont: contentItemSubLabel.font

    Behavior on implicitWidth {
        NumberAnimation {
            duration: Kirigami.Units.longDuration
            easing.type: Easing.InOutQuad
        }
    }

    Keys.onReturnPressed: (event)=> {
        clicked()
    }

    Keys.onLeftPressed: (event)=> {
        if(listView && listView.currentIndex == 0){
            settingMenuItemFocus()
        } else {
            event.accepted = false
        }
    }

    contentItem: Item {
        id: contentItemLayout

        Kirigami.Icon {
            id: contentItemSvgIcon
            width: Kirigami.Units.iconSizes.large
            height: width
            y: contentItemLayout.height/2 - contentItemSvgIcon.height/2
        }

        ColumnLayout {
            id: textLayout

            anchors {
                left: contentItemSvgIcon.right
                right: contentItemLayout.right
                top: contentItemSvgIcon.top
                bottom: contentItemSvgIcon.bottom
                leftMargin: Kirigami.Units.smallSpacing
            }

            PlasmaComponents.Label {
                id: contentItemLabel
                Layout.fillWidth: true
                visible: text.length > 0
                elide: Text.ElideRight
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                maximumLineCount: 2
                textFormat: Text.PlainText
                color: Kirigami.Theme.textColor
                font: itemLabelFont
            }

            PlasmaComponents.Label {
                id: contentItemSubLabel
                Layout.fillWidth: true
                visible: text.length > 0
                elide: Text.ElideRight
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                maximumLineCount: 2
                textFormat: Text.PlainText
                color: Kirigami.Theme.textColor
                font.pixelSize: contentItemLabel.font.pixelSize * 0.8
            }
        }

        Item {
            id: contentItemRepresentationLayout
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.rightMargin: Kirigami.Units.largeSpacing
            anchors.bottomMargin: Kirigami.Units.largeSpacing

            Kirigami.Icon {
                id: contentItemTickIcon
                anchors.centerIn: parent
                width: listView && listView.currentIndex == index && delegate.activeFocus ? Kirigami.Units.iconSizes.medium : Kirigami.Units.iconSizes.smallMedium
                height: listView && listView.currentIndex == index && delegate.activeFocus ? Kirigami.Units.iconSizes.medium : Kirigami.Units.iconSizes.smallMedium
            }
        }
    }
}