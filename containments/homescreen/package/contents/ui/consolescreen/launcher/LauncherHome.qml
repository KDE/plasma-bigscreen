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

import "delegates" as Delegates
import org.kde.bigscreen as Bigscreen
import org.kde.private.biglauncher 1.0
import org.kde.plasma.private.kicker 0.1 as Kicker

FocusScope {
    id: root

    property Item navigationUp

    
    function activateAppView() {
        gamesView.forceActiveFocus();
    }

    Component.onCompleted: activateAppView()

    ColumnLayout {
        id: launcherHomeColumn
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom

            bottomMargin: Kirigami.Units.gridUnit * 2
        }

        spacing: Kirigami.Units.largeSpacing * 3

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignLeft
            spacing: Kirigami.Units.smallSpacing
            // Show the game Icon/Poster
            Kirigami.Icon {
                Layout.alignment: Qt.AlignLeft
                Layout.preferredWidth: Kirigami.Units.gridUnit * 8
                Layout.preferredHeight: Kirigami.Units.gridUnit * 8
                // Grabs the icon name from the currently focused game delegate
                source: gamesView.currentItem ? gamesView.currentItem.icon.name : ""
            }
            // Show the game Name
            Controls.Label {
                Layout.alignment: Qt.AlignLeft
                // Grabs the text from the currently focused game delegate
                text: gamesView.currentItem ? gamesView.currentItem.text : ""
                font.pixelSize: 48
                font.weight: Font.Bold
                color: "white"
            }
        }


        DelegateListView {
            id: gamesView
            property var currentViewUpwards: root.navigationUp
            property var currentViewDownwards: null

            title: i18n("Games")
            visible: true
            enabled: true
            focus: true
            currentIndex: 0

            model: KItemModels.KSortFilterProxyModel {
                sourceModel: Plasmoid.applicationListModel
                filterRoleName: "ApplicationCategoriesRole"
                filterRowCallback: function (source_row, source_parent) {
                    return sourceModel.data(sourceModel.index(source_row, 0, source_parent), ApplicationListModel.ApplicationCategoriesRole).indexOf("Game") !== -1;
                }
            }

            delegate: Delegates.AppDelegate {
                property var modelData: typeof model !== "undefined" ? model : null
            }

            navigationUp: root.navigationUp
            navigationDown: null
        }
    }
}
