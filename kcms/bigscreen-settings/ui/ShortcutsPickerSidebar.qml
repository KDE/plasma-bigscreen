/*
    SPDX-FileCopyrightText: 2019 Aditya Mehra <aix.m@outlook.com>
    SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2

import org.kde.kirigami as Kirigami
import org.kde.bigscreen as Bigscreen
import org.kde.kquickcontrols as KQuickControls

Bigscreen.SidebarOverlay {
    id: root
    openFocusItem: resetButton

    property string title
    property string currentShortcut
    property string getActionPath
    property string setActionPath
    property string resetActionPath

    header: ColumnLayout {
        spacing: Kirigami.Units.gridUnit

        Item { Layout.fillHeight: true }
        Kirigami.Icon {
            Layout.alignment: Qt.AlignHCenter
            implicitWidth: 96
            implicitHeight: 96
            source: 'input-keyboard-symbolic'
        }
        QQC2.Label {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            maximumLineCount: 2
            elide: Text.ElideRight
            text: root.title
            font.pixelSize: 32
            font.weight: Font.Light
        }
    }

    content: ColumnLayout {
        spacing: Kirigami.Units.smallSpacing

        Keys.onLeftPressed: root.close()
        Keys.onBackPressed: root.close()

        Bigscreen.TextDelegate {
            id: shortcutLabel
            text: i18n('Shortcut currently set to')
            description: root.currentShortcut
        }

        Bigscreen.ButtonDelegate {
            id: resetButton
            icon.name: 'edit-reset'
            text: i18n("Reset to default")

            KeyNavigation.down: setButton
            visible: !newKeySequenceItem.visible

            onClicked: {
                kcm.resetShortcut(root.resetActionPath);
                root.currentShortcut = kcm.getShortcut(getActionPath);
            }
        }

        Bigscreen.ButtonDelegate {
            id: setButton
            icon.name: 'configure-shortcuts'
            text: i18n("Set Shortcut")

            KeyNavigation.up: resetButton
            visible: !newKeySequenceItem.visible

            onClicked: {
                newKeySequenceItem.visible = true;
                newKeySequenceItem.startCapturing();
            }
        }

        KQuickControls.KeySequenceItem {
            id: newKeySequenceItem
            Layout.fillWidth: true
            visible: false

            modifierlessAllowed: true
            modifierOnlyAllowed: true
            multiKeyShortcutsAllowed: false
            checkForConflictsAgainst: KQuickControls.ShortcutType.None

            onCaptureFinished: {
                visible = false;
                kcm.setShortcut(root.setActionPath, keySequence)
                root.currentShortcut = keySequence.toString()

                setButton.forceActiveFocus();
            }
        }

        Item { Layout.fillHeight: true }
    }
}