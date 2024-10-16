/*
    SPDX-FileCopyrightText: 2019 Aditya Mehra <aix.m@outlook.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.extras as PlasmaExtras
import org.kde.kirigami as Kirigami
import org.kde.bigscreen as BigScreen
import org.kde.kquickcontrols as KQuickControls
import Qt5Compat.GraphicalEffects



Item {
    id: main

    onActiveFocusChanged: {
        if(activeFocus){
            resetButton.forceActiveFocus()
        }
    }

    Keys.onBackPressed: {
        backBtnSettingsItem.clicked()
    }

    Item {
        id: emptyArea
        height: Kirigami.Units.gridUnit * 2
        width: parent.width
        anchors.top: parent.top
    }

    ColumnLayout {
        id: contentLayout
        anchors {
            top: emptyArea.bottom
            left: parent.left
            right: parent.right
            margins: Kirigami.Units.largeSpacing * 2
        }

        Kirigami.Icon {
            id: dIcon
            Layout.alignment: Qt.AlignTop | Qt.AlignHCenter
            Layout.preferredWidth: parent.width
            Layout.preferredHeight: width / 3
            source: "input-keyboard-symbolic"
        }

        Kirigami.Heading {
            id: label1
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignTop | Qt.AlignHCenter
            Layout.topMargin: Kirigami.Units.largeSpacing
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            level: 2
            maximumLineCount: 2
            elide: Text.ElideRight
            color: Kirigami.Theme.textColor
            text: i18n("Update Shortcut Keys")
        }

        Kirigami.Separator {
            id: lblSept
            Layout.alignment: Qt.AlignTop | Qt.AlignHCenter
            Layout.topMargin: Kirigami.Units.largeSpacing
            Layout.preferredHeight: 1
            Layout.fillWidth: true
        }


        Kirigami.Heading {
            id: label2
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignTop | Qt.AlignHCenter
            Layout.topMargin: Kirigami.Units.largeSpacing
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            level: 2
            maximumLineCount: 2
            elide: Text.ElideRight
            color: Kirigami.Theme.textColor
            text: settingsAreaLoader.currentShortcut
        }

        Kirigami.Separator {
            id: lblSept2
            Layout.alignment: Qt.AlignTop | Qt.AlignHCenter
            Layout.topMargin: Kirigami.Units.largeSpacing
            Layout.preferredHeight: 1
            Layout.fillWidth: true
        }

        Button {
            id: resetButton
            Layout.fillWidth: true
            Layout.preferredHeight: Kirigami.Units.gridUnit * 4
            Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
            text: i18n("Reset Default")
            KeyNavigation.down: setButton
            onClicked: {
                kcm.resetShortcut(settingsAreaLoader.setActionPath)
            }
            Keys.onReturnPressed: clicked()
            visible: newKeySequenceItem.visible ? false : true
        }

        Button {
            id: setButton
            Layout.fillWidth: true
            Layout.preferredHeight: Kirigami.Units.gridUnit * 4
            Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
            text: i18n("Set Shortcut")
            KeyNavigation.up: resetButton
            KeyNavigation.down: backBtnSettingsItem
            onClicked: {
                newKeySequenceItem.visible = true
                newKeySequenceItem.startCapturing()
            }
            Keys.onReturnPressed: clicked()
            visible: newKeySequenceItem.visible ? false : true
        }

        KQuickControls.KeySequenceItem {
            id: newKeySequenceItem
            visible: false

            modifierlessAllowed: true
            modifierOnlyAllowed: true
            multiKeyShortcutsAllowed: false
            checkForConflictsAgainst: KQuickControls.ShortcutType.None

            onCaptureFinished: {
                visible = false
                kcm.setShortcut(settingsAreaLoader.setActionPath, keySequence)
                label2.text = keySequence.toString()
            }
        }
    }

    Kirigami.Separator {
        id: footerAreaSettingsSept
        anchors.bottom: footerAreaSettingsItem.top
        anchors.bottomMargin: Kirigami.Units.largeSpacing
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: Kirigami.Units.largeSpacing * 2
        anchors.rightMargin: Kirigami.Units.largeSpacing * 2
        height: 1
    }

    RowLayout {
        id: footerAreaSettingsItem
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: Kirigami.Units.largeSpacing * 2
        height: Kirigami.Units.gridUnit * 2

        PlasmaComponents.Button {
            id: backBtnSettingsItem
            icon.name: "arrow-left"
            Layout.alignment: Qt.AlignLeft

            PlasmaExtras.Highlight {
                z: -2
                anchors.fill: parent
                anchors.margins: -Kirigami.Units.gridUnit / 4
                visible: backBtnSettingsItem.activeFocus ? 1 : 0
            }

            Keys.onReturnPressed: {
                clicked()
            }

            onClicked: {
                settingsAreaLoader.opened = false
                timeDateSettingsDelegate.forceActiveFocus()
            }
        }

        Label {
            id: backbtnlabelHeading
            text: i18n("Press the [←] Back button to return to appearance settings")
            wrapMode: Text.WordWrap
            maximumLineCount: 2
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignRight
        }
    }
}