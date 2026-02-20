/*
    SPDX-FileCopyrightText: 2015 Aleix Pol Gonzalez <aleixpol@kde.org>
    SPDX-FileCopyrightText: 2020 Aditya Mehra <aix.m@outlook.com>
    SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>

    SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2

import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami
import org.kde.bigscreen as Bigscreen
import org.kde.kdeconnect

import "delegates" as Delegates

Bigscreen.SidebarOverlay {
    id: root
    openFocusItem: deviceStackLayout

    property QtObject currentDevice
    property bool isPairRequested: currentDevice.isPairRequested
    property bool isPaired: currentDevice.isPaired
    property bool isReachable: currentDevice.isReachable

    onCurrentDeviceChanged: checkCurrentStatus()

    onIsPairRequestedChanged: {
        if(isPairRequested) {
            checkCurrentStatus()
        }
    }

    onIsPairedChanged: checkCurrentStatus()
    onIsReachableChanged: checkCurrentStatus()

    function checkCurrentStatus() {
        if (currentDevice.isReachable) {
            if (currentDevice.isPaired) {
                deviceStackLayout.currentIndex = 2
            } else if (currentDevice.isPairRequested) {
                deviceStackLayout.currentIndex = 1;
            } else {
                deviceStackLayout.currentIndex = 0
            }

        } else {
            deviceStackLayout.currentIndex = 3
        }
    }

    header: Bigscreen.SidebarOverlayHeader {
        iconSource: currentDevice.iconName
        title: currentDevice.name
    }

    content: ColumnLayout {
        id: colLayoutSettingsItem

        Keys.onLeftPressed: root.close();

        StackLayout {
            id: deviceStackLayout
            Layout.fillWidth: true
            Layout.fillHeight: true

            onActiveFocusChanged: {
                if (activeFocus) {
                    children[currentIndex].forceActiveFocus();
                }
            }

            onCurrentIndexChanged: {
                if (root.visible) {
                    children[currentIndex].forceActiveFocus();
                }
            }

            Delegates.UnpairedView {
                id: unpairedView
                onPairingRequested: root.currentDevice.requestPairing()
            }

            Delegates.PairRequest {
                id: pairRequestView
                onAcceptPairingRequested: root.currentDevice.acceptPairing()
                onRejectPairingRequested: root.currentDevice.rejectPairing()
            }

            Delegates.PairedView {
                id: pairedView
                onUnpairRequested: {
                    root.currentDevice.unpair()
                    root.close()
                    connectionView.forceActiveFocus();
                }
            }

            Delegates.Unreachable { 
                id: unreachableView
                onUnpairRequested: {
                    root.currentDevice.unpair()
                    root.close()
                    connectionView.forceActiveFocus();
                }   
            }
        }
    }
}
