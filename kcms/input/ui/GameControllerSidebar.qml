/*
 * SPDX-FileCopyrightText: 2026 Devin Lin <devin@kde.org>
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick
import QtQuick.Layouts

import org.kde.kirigami as Kirigami
import org.kde.bigscreen as Bigscreen

Bigscreen.SidebarOverlay {
    id: root
    openFocusItem: enabledDelegate

    property var controller: null
    readonly property string uniqueIdentifier: controller ? controller.uniqueIdentifier : ""
    readonly property bool controllerEnabled: controller ? controller.controllerEnabled : true
    readonly property bool startButtonEnabledWhenSuppressed: controller ? controller.startButtonEnabledWhenSuppressed : true
    property bool inputEnabled: true
    readonly property bool typeEnabled: controller ? controller.enabled : true

    header: Bigscreen.SidebarOverlayHeader {
        iconSource: root.controller ? root.controller.iconName : "input-gamepad"
        title: root.controller ? root.controller.name : ""
    }

    content: ColumnLayout {
        spacing: Kirigami.Units.smallSpacing

        Keys.onLeftPressed: root.close()
        Keys.onBackPressed: root.close()

        Bigscreen.SwitchDelegate {
            id: enabledDelegate
            text: i18n("System navigation")
            enabled: root.inputEnabled && root.typeEnabled
            checked: root.controllerEnabled

            KeyNavigation.down: startButtonDelegate

            onCheckedChanged: {
                if (root.controllerEnabled !== checked) {
                    kcm.setControllerEnabled(root.uniqueIdentifier, checked);
                }
            }
        }

        Bigscreen.SwitchDelegate {
            id: startButtonDelegate
            text: i18n("START button when suppressed")
            description: i18n("Handle the START button even when input is suppressed (may conflict with some apps)")
            enabled: root.inputEnabled && root.typeEnabled
            checked: root.startButtonEnabledWhenSuppressed

            KeyNavigation.up: enabledDelegate

            onCheckedChanged: {
                if (root.startButtonEnabledWhenSuppressed !== checked) {
                    kcm.setStartButtonEnabledWhenSuppressed(root.uniqueIdentifier, checked);
                }
            }
        }

        Item {
            Layout.fillHeight: true
        }
    }
}
