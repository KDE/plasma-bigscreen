/*
    SPDX-FileCopyrightText: 2020 Aditya Mehra <aix.m@outlook.com>
    SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>

    SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL

*/

import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls as QQC2

import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import org.kde.bigscreen as Bigscreen
import org.kde.kitemmodels as KItemModels

Kirigami.ScrollablePage {
    id: root

    title: i18n("Display Configuration")

    background: null
    leftPadding: Kirigami.Units.smallSpacing
    topPadding: Kirigami.Units.smallSpacing
    rightPadding: Kirigami.Units.smallSpacing
    bottomPadding: Kirigami.Units.smallSpacing

    onActiveFocusChanged: {
        if (activeFocus) {
            selectedDisplayDelegate.forceActiveFocus();
        }
    }

    contentItem: ColumnLayout {
        spacing: 0
        KeyNavigation.left: root.KeyNavigation.left

        Bigscreen.ComboBoxDelegate {
            id: selectedDisplayDelegate
            text: i18n('Selected display')
            icon.name: 'preferences-desktop-display-randr-symbolic'

            model: kcm.displayModel
            textRole: 'outputName'
            valueRole: 'id'

            function updateIndex() {
                if (kcm.displayModel.selectedDisplayId != -1) {
                    selectedDisplayDelegate.currentIndex = selectedDisplayDelegate.indexOfValue(kcm.displayModel.selectedDisplayId);
                }
            }

            // Update the combobox value when the model updates or display changes
            onCountChanged: updateIndex()
            Component.onCompleted: updateIndex()
            Connections {
                target: kcm.displayModel
                function onSelectedDisplayIdChanged() {
                    selectedDisplayDelegate.updateIndex();
                }
            }

            onActivated: {
                kcm.displayModel.selectedDisplayId = currentValue;
                updateIndex();
            }

            KeyNavigation.down: enabledDelegate
        }

        QQC2.Label {
            text: i18n('Display %1', kcm.displayModel.selectedDisplayName)
            font.pixelSize: 22
            font.weight: Font.Normal
            Layout.topMargin: Kirigami.Units.gridUnit
            Layout.bottomMargin: Kirigami.Units.gridUnit
        }

        Bigscreen.SwitchDelegate {
            id: enabledDelegate
            text: i18n('Enabled')
            visible: selectedDisplayDelegate.count > 1 // Only show if we have more than one screen
            checked: kcm.displayModel.selectedDisplayEnabled

            onClicked: {
                kcm.displayModel.selectedDisplayEnabled = checked;
                kcm.displayModel.syncDisplayOptions();
                checked = Qt.binding(() => kcm.displayModel.selectedDisplayEnabled);
            }

            KeyNavigation.down: modeDelegate
        }

        Bigscreen.ComboBoxDelegate {
            id: modeDelegate
            text: i18n('Screen mode (Resolution & Refresh Rate)')
            model: kcm.displayModel.selectedDisplayAvailableModes
            enabled: kcm.displayModel.selectedDisplayEnabled

            function updateIndex() {
                if (enabled) {
                    currentIndex = indexOfValue(kcm.displayModel.selectedDisplayMode);
                }
            }

            // Update the combobox value when the model updates or display changes
            Component.onCompleted: updateIndex()
            Connections {
                target: kcm.displayModel
                function onSelectedDisplayIdChanged() {
                    modeDelegate.updateIndex();
                }
            }

            onActivated: {
                kcm.displayModel.selectedDisplayMode = currentValue;
                updateIndex();
            }

            KeyNavigation.down: scaleDelegate
        }

        Bigscreen.ButtonDelegate {
            id: scaleDelegate
            text: i18n('Scale')
            description: Math.round(kcm.displayModel.selectedDisplayScale * 100) + "%"
            enabled: kcm.displayModel.selectedDisplayEnabled

            onClicked: {
                scaleDialog.displayScale = kcm.displayModel.selectedDisplayScale;
                scaleDialog.open();
            }

            ScaleDialog {
                id: scaleDialog
                onClosed: scaleDelegate.forceActiveFocus()

                onAccepted: {
                    kcm.displayModel.selectedDisplayScale = scaleDialog.displayScale;
                    kcm.displayModel.syncDisplayOptions();
                }
            }
        }

        Item { Layout.fillHeight: true }
    }
}
