/*
    SPDX-FileCopyrightText: 2019 Aditya Mehra <aix.m@outlook.com>
    SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>

    SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Window
import QtQuick.Controls as QQC2

import org.kde.kirigami as Kirigami
import org.kde.bigscreen as Bigscreen


Bigscreen.SidebarOverlay {
    id: root
    openFocusItem: colorSchemeView

    header: Bigscreen.SidebarOverlayHeader {
        iconSource: 'preferences-desktop-color'
        title: i18n("Color scheme")
    }

    content: ColumnLayout {

        GridView {
            id: colorSchemeView
            Layout.fillWidth: true
            Layout.fillHeight: true

            Keys.onLeftPressed: root.close()
            Keys.onBackPressed: root.close()

            clip: true
            model: kcm.colorSchemeListModel
            cacheBuffer: parent.width * 2

            cellWidth: width
            cellHeight: Kirigami.Units.gridUnit * 8

            delegate: Bigscreen.ButtonDelegate {
                id: delegate
                width: colorSchemeView.cellWidth
                height: colorSchemeView.cellHeight

                onClicked: kcm.colorSchemeListModel.setColorScheme(model.schemeNameRole)

                contentItem: Item {
                    id: colorSchemeItemLayout
                    property var swatchColors: [
                        model.windowColorRole,
                        model.textColorRole,
                        model.buttonColorRole,
                        model.highlightColorRole,
                        model.highlightedTextColorRole
                    ]

                    Rectangle {
                        id: preview
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.margins: Kirigami.Units.smallSpacing
                        color: model.windowColorRole
                        radius: Kirigami.Units.cornerRadius

                        Rectangle {
                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: Kirigami.Units.gridUnit * 3
                            color: model.activeTitleBarBackgroundRole
                            opacity: 0.95

                            QQC2.Label {
                                id: nameLabel
                                anchors.fill: parent
                                visible: text.length > 0
                                elide: Text.ElideRight
                                wrapMode: Text.WordWrap
                                maximumLineCount: 2
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                color: model.activeTitleBarForegroundRole
                                text: model.packageNameRole
                                font.pixelSize: height * 0.4
                            }
                        }

                        RowLayout {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            anchors.margins: Kirigami.Units.gridUnit
                            spacing: Kirigami.Units.smallSpacing

                            Repeater {
                                model: colorSchemeItemLayout.swatchColors

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: Kirigami.Units.gridUnit
                                    color: modelData
                                    border.width: 1
                                    border.color: Qt.rgba(0, 0, 0, 0.25)
                                }
                            }
                        }
                    }

                    Kirigami.Icon {
                        id: dIcon
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: -Kirigami.Units.smallSpacing
                        anchors.right: parent.right
                        anchors.rightMargin: -Kirigami.Units.smallSpacing
                        width: Kirigami.Units.iconSizes.smallMedium
                        height: width
                        source: 'dialog-positive'
                        visible: kcm.colorSchemeName === model.schemeNameRole
                    }
                }
            }
        }
    }
}
