/*
    SPDX-FileCopyrightText: 2018 Aditya Mehra <aix.m@outlook.com>
    SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>

    SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL

*/

import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls as QQC2

import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami
import org.kde.plasma.networkmanagement as PlasmaNM
import org.kde.kcmutils as KCM
import org.kde.bigscreen as Bigscreen

import "views" as Views
import "delegates" as Delegates

KCM.SimpleKCM {
    id: networkSelectionView

    title: i18n("Network")
    background: null

    leftPadding: Kirigami.Units.smallSpacing
    topPadding: Kirigami.Units.smallSpacing
    rightPadding: Kirigami.Units.smallSpacing
    bottomPadding: Kirigami.Units.smallSpacing

    property var securityType
    property var connectionName
    property var devicePath
    property var specificPath

    property Item settingMenuItem: networkSelectionView.parent.parent.lastSettingMenuItem

    function settingMenuItemFocus() {
        settingMenuItem.forceActiveFocus()
    }

    onActiveFocusChanged: {
        if (activeFocus) {
            handler.requestScan();
            refreshButton.forceActiveFocus();
        }
    }

    PlasmaNM.EnabledConnections {
        id: enabledConnections
    }

    PlasmaNM.NetworkStatus {
        id: networkStatus
    }

    PlasmaNM.ConnectionIcon {
        id: connectionIconProvider
    }

    PlasmaNM.Handler {
        id: handler
    }

    PlasmaNM.AvailableDevices {
        id: availableDevices
    }

    PlasmaNM.NetworkModel {
        id: connectionModel
    }

    Component {
        id: networkModelComponent
        PlasmaNM.NetworkModel {}
    }

    PlasmaNM.AppletProxyModel {
        id: appletProxyModel
        sourceModel: connectionModel
    }

    PlasmaNM.AppletProxyModel {
        id: connectedProxyModel
        sourceModel: connectionModel
    }

    onRefreshingChanged: {
        if (refreshing) {
            refreshTimer.restart()
            handler.requestScan();
        }
    }
    Timer {
        id: refreshTimer
        interval: 3000
        onTriggered: networkSelectionView.refreshing = false
    }

    contentItem: ColumnLayout {
        id: column
        spacing: 0

        Bigscreen.ButtonDelegate {
            id: refreshButton
            raisedBackground: false
            text: i18n("Refresh")
            icon.name: "view-refresh"

            KeyNavigation.down: networkDelegateList

            onClicked: {
                networkSelectionView.refreshing = true;
            }
        }

        QQC2.Label {
            text: i18n('Connections')
            font.pixelSize: 22
            font.weight: Font.Normal
            Layout.topMargin: Kirigami.Units.gridUnit
            Layout.bottomMargin: Kirigami.Units.smallSpacing
        }

        ListView {
            id: networkDelegateList
            Layout.fillWidth: true
            Layout.fillHeight: true

            clip: true
            model: appletProxyModel
            spacing: Kirigami.Units.smallSpacing

            delegate: Delegates.NetworkDelegate {
                id: delegate
                width: networkDelegateList.width
                smallDescription: true
                raisedBackground: false

                // Update sidebar overlay with correct delegate when there is model changes/reordering
                onTextChanged: {
                    if (sidebarOverlay.modelItemUniqueName === model.ItemUniqueName) {
                        sidebarOverlay.changeModel(delegate.model);
                        sidebarOverlay.delegate = delegate;
                    }
                }

                onClicked: {
                    sidebarOverlay.changeModel(delegate.model);
                    sidebarOverlay.delegate = delegate
                    sidebarOverlay.open();
                }
            }
        }

        // Needs to be here to be visible
        DeviceConnectionSidebar {
            id: sidebarOverlay

            property var delegate
            onClosed: delegate.forceActiveFocus()
        }
    }
}
