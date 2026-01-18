// SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import QtQuick.Window
import QtQuick.Controls as QQC2

import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.private.nanoshell as NanoShell
import org.kde.bigscreen as Bigscreen

import org.kde.milou as Milou
import org.kde.kirigami as Kirigami

Milou.ResultsView {
    id: root

    property var queryTextField
    signal hideOverlayRequested()

    queryString: queryTextField.text
    clip: true
    keyNavigationEnabled: true
    highlight: null

    Keys.onUpPressed: {
        currentIndex--;
        Bigscreen.NavigationSoundEffects.playMovingSound();
    }
    Keys.onDownPressed: {
        if (currentIndex < (root.count - 1)) {
            currentIndex++;
            Bigscreen.NavigationSoundEffects.playMovingSound();
        }
    }

    onActivated: {
        root.hideOverlayRequested();
    }
    onUpdateQueryString: {
        queryTextField.text = text
        queryTextField.cursorPosition = cursorPosition
    }

    // Section header
    section.delegate: QQC2.Control {
        id: sectionHeader
        required property string section

        topPadding: Kirigami.Units.gridUnit
        bottomPadding: Kirigami.Units.largeSpacing
        leftPadding: 0
        rightPadding: 0

        contentItem: Kirigami.Heading {
            opacity: 0.7
            text: sectionHeader.section
            elide: Text.ElideRight

            font.weight: Font.Medium
            Accessible.ignored: true
        }
    }

    delegate: Bigscreen.ButtonDelegate {
        id: delegate
        width: listView.width

        raisedBackground: false

        // Go to search bar if this we press up with the first item selected
        KeyNavigation.up: model.index === 0 ? queryTextField : null

        // Used by ResultsView to determine next tab action
        function activateNextAction() {
            queryTextField.forceActiveFocus();
            queryTextField.selectAll();
            listView.currentIndex = -1;
        }

        onClicked: {
            listView.currentIndex = model.index;
            listView.runCurrentIndex();

            root.hideOverlayRequested();
        }

        leading: Kirigami.Icon {
            source: model.decoration
            implicitWidth: Kirigami.Units.iconSizes.large
            implicitHeight: Kirigami.Units.iconSizes.large
        }

        text: typeof modelData !== "undefined" ? modelData : model.display
        description: model.subtext || ""
    }
}
