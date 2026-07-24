/*
    SPDX-FileCopyrightText: 2019 Aditya Mehra <aix.m@outlook.com>
    SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import QtQuick.Window

import org.kde.plasma.plasmoid
import org.kde.kquickcontrolsaddons
import org.kde.kirigami as Kirigami
import org.kde.kitemmodels as KItemModels

import org.kde.bigscreen as Bigscreen
import org.kde.private.biglauncher
import org.kde.plasma.private.kicker as Kicker

import "delegates" as Delegates

FocusScope {
    id: root
    property Item navigationUp

    readonly property string activeHeroPath: gamesView.currentItem?.gameData?.hero_path ?? ""

    function activateAppView() {
        gamesView.forceActiveFocus();
    }

    Component.onCompleted: activateAppView()

    ColumnLayout {
        id: launcherHomeColumn
        anchors.fill:parent
        anchors.bottomMargin: Kirigami.Units.largeSpacing * 4
        spacing: Kirigami.Units.largeSpacing * 4

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }

        GameDelegateListView {
            id: gamesView
    
            property var currentViewUpwards: root.navigationUp
            property var currentViewDownwards: null

            Layout.fillWidth: true
            Layout.fillHeight: false

            focus: true
            currentIndex: 0

            //our game database
            model:GameManager.getGames()
            delegate: Delegates.GameDelegate {}

            navigationUp: root.navigationUp
            navigationDown: null
        }

        GamePanel {
            Layout.fillWidth: true
            Layout.fillHeight: false

            Layout.preferredHeight: implicitHeight
            Layout.minimumHeight: implicitHeight

            modelData: gamesView.currentItem ? gamesView.currentItem.gameData : null
        }
    }
}
