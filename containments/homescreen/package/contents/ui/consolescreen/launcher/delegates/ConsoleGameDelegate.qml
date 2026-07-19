// SPDX-FileCopyrightText: 2025 Your Name <your@email.com>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import org.kde.bigscreen as Bigscreen

Item {
    id: delegate
    
    property bool isCurrentItem: ListView.isCurrentItem
    
    // Properties from model
    property string applicationStorageId: model.ApplicationStorageIdRole || ""
    property string text: model.ApplicationNameRole || ""
    property string iconImage: model.ApplicationIconRole || ""
    
    width: Kirigami.Units.gridUnit * 14
    height: Kirigami.Units.gridUnit * 20
    
    scale: isCurrentItem ? 1.05 : 0.95
    Behavior on scale { NumberAnimation { duration: 150 } }
    
    // Game cover background
    Rectangle {
        id: coverBg
        anchors.fill: parent
        radius: Kirigami.Units.largeSpacing
        color: isCurrentItem ? Qt.rgba(1, 1, 1, 0.1) : Qt.rgba(0, 0, 0, 0.4)
        border.color: isCurrentItem ? "red" : "transparent"
        border.width: isCurrentItem ? 4 : 0
        clip: true
        
        Behavior on border.color { ColorAnimation { duration: 150 } }
        Behavior on color { ColorAnimation { duration: 150 } }
        
        // Icon
        Kirigami.Icon {
            anchors.centerIn: parent
            width: parent.width * 0.6
            height: width
            source: delegate.iconImage
            opacity: isCurrentItem ? 1.0 : 0.7
            Behavior on opacity { NumberAnimation { duration: 150 } }
        }
    }
    
    // Accept input
    Keys.onReturnPressed: delegate.clicked()
    Keys.onEnterPressed: delegate.clicked()
    
    MouseArea {
        anchors.fill: parent
        onClicked: {
            delegate.ListView.view.currentIndex = index;
            delegate.clicked();
        }
    }
    
    function clicked() {
        Bigscreen.NavigationSoundEffects.playClickedSound();
        if (Plasmoid.applicationListModel.isApplicationRunning(delegate.applicationStorageId)) {
            Plasmoid.applicationListModel.maximizeApplication(delegate.applicationStorageId);
        } else {
            Plasmoid.showAppLaunchScreen(delegate.text, delegate.iconImage);
            Plasmoid.applicationListModel.runApplication(delegate.applicationStorageId);
        }
    }
}
