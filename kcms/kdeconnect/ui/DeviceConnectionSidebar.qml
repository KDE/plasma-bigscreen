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
        // if (currentDevice.isPairRequested) {
        //     deviceStackLayout.currentIndex = 1;
        // } else
        // disable pairing request handler in kcm as indicator handles pairing in bigscreen

        if (currentDevice.isReachable) {
            if (currentDevice.isPaired) {
                deviceIconStatus.source = currentDevice.statusIconName
                deviceStackLayout.currentIndex = 2

            } else {
                deviceIconStatus.source = currentDevice.iconName
                deviceStackLayout.currentIndex = 0
            }

        } else {
            deviceStackLayout.currentIndex = 3
        }
    }

    header: ColumnLayout {
        spacing: Kirigami.Units.gridUnit

        Item { Layout.fillHeight: true }
        Kirigami.Icon {
            id: deviceIconStatus
            Layout.alignment: Qt.AlignHCenter
            implicitWidth: 96
            implicitHeight: 96
            source: currentDevice.iconName
        }
        QQC2.Label {
            id: deviceLabel
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            maximumLineCount: 2
            elide: Text.ElideRight
            text: currentDevice.name
            font.pixelSize: 32
            font.weight: Font.Light
        }
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
                onUnpairRequested: root.currentDevice.unpair()
            }

            Delegates.Unreachable { id: unreachableView }
        }
    }
}
