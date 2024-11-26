/*
    SPDX-FileCopyrightText: 2020 Aditya Mehra <aix.m@outlook.com>

    SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL

*/

import QtQuick.Layouts
import QtQuick
import QtQuick.Window
import QtQuick.Controls
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import org.kde.bigscreen as BigScreen
import org.kde.kitemmodels as KItemModels
import "delegates" as Delegates

KCM.SimpleKCM {
    id: displayKCMRoot
    title: i18n("Display Configuration")
    background: null
    leftPadding: Kirigami.Units.smallSpacing
    topPadding: 0
    rightPadding: Kirigami.Units.smallSpacing
    bottomPadding: 0

    property Item settingMenuItem: displayKCMRoot.parent.parent.lastSettingMenuItem

    function settingMenuItemFocus() {
        settingMenuItem.forceActiveFocus()
    } 

    onFocusChanged: {
        if(focus) {
            displayRepeater.currentItem.forceActiveFocus();
        }
    }

    contentItem: FocusScope {
        Item {
            anchors.left: parent.left
            anchors.leftMargin: Kirigami.Units.largeSpacing
            anchors.top: parent.top
            anchors.topMargin: Kirigami.Units.largeSpacing * 2
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.rightMargin: Kirigami.Units.largeSpacing
            clip: true

            Rectangle {
                id: viewContentHeaderArea
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: Kirigami.Units.gridUnit * 12
                color: Kirigami.Theme.alternateBackgroundColor
                radius: 6

                RowLayout {
                    id: viewContentHeaderLayout
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.topMargin: Kirigami.Units.largeSpacing
                    anchors.leftMargin: Kirigami.Units.largeSpacing
                    anchors.rightMargin: Kirigami.Units.largeSpacing
                    height: Kirigami.Units.gridUnit * 4
                    spacing: Kirigami.Units.largeSpacing

                    Kirigami.Icon {
                        id: displayIcon
                        source: "video-display"
                        Layout.fillHeight: true
                        Layout.preferredWidth: height
                    }

                    Kirigami.Heading {
                        id: displayTitle
                        text: displayRepeater.currentItem.displayOutputName
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        verticalAlignment: Text.AlignBottom
                        horizontalAlignment: Text.AlignLeft
                        font.bold: true
                        color: Kirigami.Theme.textColor
                        fontSizeMode: Text.Fit
                        minimumPixelSize: 16
                        font.pixelSize: 32
                    }

                    Button {
                        id: previousDisplayButton
                        Layout.preferredWidth: Kirigami.Units.gridUnit * 4
                        Layout.fillHeight: true
                        icon.name: "arrow-left"
                        KeyNavigation.left: settingMenuItem
                        KeyNavigation.right: nextDisplayButton
                        KeyNavigation.down: displayRepeater
                        enabled: displayRepeater.currentIndex > 0
                        onClicked: {
                            displayRepeater.decrementCurrentIndex()
                        }
                    }

                    Button {
                        id: nextDisplayButton
                        Layout.preferredWidth: Kirigami.Units.gridUnit * 4
                        Layout.fillHeight: true
                        icon.name: "arrow-right"
                        KeyNavigation.left: previousDisplayButton
                        KeyNavigation.down: displayRepeater
                        enabled: displayRepeater.currentIndex < displayRepeater.count - 1
                        onClicked: {
                            displayRepeater.incrementCurrentIndex()
                        }
                    }
                }

                Delegates.LocalSettingCurrentResolution {
                    id: resolutionCurrentDelegate
                    anchors.top: viewContentHeaderLayout.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.leftMargin: Kirigami.Units.largeSpacing
                    anchors.rightMargin: Kirigami.Units.largeSpacing
                    anchors.bottomMargin: Kirigami.Units.largeSpacing
                    currentResolution: displayRepeater.currentItem.displaySizeString
                    currentRefreshRate: displayRepeater.currentItem.displayCurrentRefreshRate
                    currentModeId: displayRepeater.currentItem.displayCurrentModeId
                }
            }

            ColumnLayout {
                id: repeaterContentLayout
                anchors.top: viewContentHeaderArea.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: Kirigami.Units.largeSpacing

                ListView {
                    id: displayRepeater
                    layoutDirection: Qt.LeftToRight
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignTop
                    orientation: ListView.Horizontal
                    snapMode: ListView.SnapOneItem;
                    highlightRangeMode: ListView.StrictlyEnforceRange;
                    highlightFollowsCurrentItem: true
                    spacing: Kirigami.Units.largeSpacing
                    clip: true
                    
                    model:  KItemModels.KSortFilterProxyModel {
                        sourceModel: kcm.displayModel
                        filterRoleName: "enabled"
                        filterString: "true"
                    }

                    delegate: Delegates.DisplayDelegate {
                        width: displayRepeater.width
                        height: displayRepeater.height
                    }

                    Component.onCompleted: {
                        currentItem.forceActiveFocus();
                    }
                }
            }
        }
    }

    Delegates.ConfirmationDialog {
        id: confirmationDialog
    }
}