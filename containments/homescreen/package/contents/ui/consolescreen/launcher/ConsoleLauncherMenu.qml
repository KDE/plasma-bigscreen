// SPDX-FileCopyrightText: 2025 Your Name <your@email.com>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import org.kde.plasma.plasmoid
import org.kde.kitemmodels as KItemModels
import org.kde.kirigami as Kirigami
import "delegates" as Delegates
import org.kde.private.biglauncher 1.0

FocusScope {
    id: root
    
    property real startY
    property real leftMargin
    property real rightMargin
    
    // Whether the view has scrolled down at least one row
    readonly property bool scrolledDown: false
    
    property Item currentSection: gameList
    
    // The current game title for the background logic
    property string currentAppId: gameList.currentItem ? gameList.currentItem.applicationStorageId : ""
    property string currentAppIcon: gameList.currentItem ? gameList.currentItem.iconImage : ""

    ListView {
        id: gameList
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Kirigami.Units.gridUnit * 6
        height: Kirigami.Units.gridUnit * 22
        
        orientation: ListView.Horizontal
        spacing: Kirigami.Units.largeSpacing * 2
        
        // Padding for the sides to allow snapping to center
        leftMargin: root.leftMargin + width / 2 - (Kirigami.Units.gridUnit * 7)
        rightMargin: root.rightMargin + width / 2 - (Kirigami.Units.gridUnit * 7)
        
        snapMode: ListView.SnapToItem
        highlightRangeMode: ListView.StrictlyEnforceRange
        preferredHighlightBegin: width / 2 - (Kirigami.Units.gridUnit * 7)
        preferredHighlightEnd: width / 2 + (Kirigami.Units.gridUnit * 7)
        
        focus: true
        
        model: KItemModels.KSortFilterProxyModel {
            sourceModel: Plasmoid.applicationListModel
            filterRoleName: "ApplicationCategoriesRole"
            filterRowCallback: function (source_row, source_parent) {
                // Show games. We return true for now to make sure apps show up during testing
                var cats = sourceModel.data(sourceModel.index(source_row, 0, source_parent), ApplicationListModel.ApplicationCategoriesRole) || "";
                return cats.indexOf("Game") !== -1; 
            }
        }
        
        delegate: Delegates.ConsoleGameDelegate {
            id: del
        }
        
        onActiveFocusChanged: {
            if (activeFocus) {
                root.currentSection = gameList
            }
        }
    }
    
    // Game Title text
    Controls.Label {
        anchors.top: gameList.bottom
        anchors.topMargin: Kirigami.Units.largeSpacing
        anchors.left: parent.left
        anchors.leftMargin: root.leftMargin
        
        text: gameList.currentItem ? gameList.currentItem.text.toUpperCase() : ""
        font.pixelSize: Kirigami.Units.gridUnit * 2
        font.weight: Font.Bold
        color: "white"
        style: Text.Outline
        styleColor: "black"
    }
}
