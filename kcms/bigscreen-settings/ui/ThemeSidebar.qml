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
    openFocusItem: desktopThemeView

    header: ColumnLayout {
        spacing: Kirigami.Units.gridUnit

        Item { Layout.fillHeight: true }
        Kirigami.Icon {
            Layout.alignment: Qt.AlignHCenter
            implicitWidth: 96
            implicitHeight: 96
            source: 'preferences-desktop-theme'
        }
        QQC2.Label {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            maximumLineCount: 2
            elide: Text.ElideRight
            text: i18n('Global theme')
            font.pixelSize: 32
            font.weight: Font.Light
        }
    }

    content: ColumnLayout {

        GridView {
            id: desktopThemeView
            Layout.fillWidth: true
            Layout.fillHeight: true

            Keys.onLeftPressed: root.close()
            Keys.onBackPressed: root.close()

            clip: true
            model: kcm.globalThemeListModel
            cacheBuffer: parent.width * 2

            cellWidth: width
            cellHeight: Kirigami.Units.gridUnit * 16

            delegate: Bigscreen.ButtonDelegate {
                id: delegate
                width: desktopThemeView.cellWidth
                height: desktopThemeView.cellHeight

                onClicked: kcm.globalThemeListModel.setTheme(model.pluginIdRole)

                contentItem: Item {
                    id: connectionItemLayout

                    Image {
                        id: preview
                        anchors.fill: parent
                        fillMode: Image.PreserveAspectFit
                        source: Qt.resolvedUrl(model.previewPathRole)

                        Rectangle {
                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: Kirigami.Units.gridUnit * 3
                            color: Kirigami.Theme.backgroundColor
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
                                color: Kirigami.Theme.textColor
                                text: model.packageNameRole
                                font.pixelSize: height * 0.4
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
                        visible: kcm.themeName === model.packageNameRole
                    }
                }
            }
        }
    }
}