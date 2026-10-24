/*
    SPDX-FileCopyrightText: 2026 User8395 <therealuser8395@proton.me>
    SPDX-FileCopyrightText: 2026 Devin Lin <devin@kde.org>

    SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL
*/

import QtQuick
import QtQuick.Controls as QQC2

import org.kde.bigscreen as Bigscreen

Bigscreen.Dialog {
    id: root

    title: i18n("Keep display configuration?")
    standardButtons: Bigscreen.Dialog.Ok | Bigscreen.Dialog.Cancel

    property int timeout: 15
    property int revertCountdown: timeout

    property var revertAction: null
    property Item returnFocusItem: null

    function confirm(focusItem, revert) {
        returnFocusItem = focusItem;
        revertAction = revert;
        open();
    }

    onOpened: {
        revertCountdown = timeout;
        revertTimer.restart();
    }
    onClosed: {
        revertTimer.stop();
        revertAction = null;
        if (returnFocusItem) {
            returnFocusItem.forceActiveFocus();
        }
    }
    onRejected: {
        if (revertAction) {
            revertAction();
        }
    }

    Timer {
        id: revertTimer
        interval: 1000
        repeat: true

        onTriggered: {
            root.revertCountdown -= 1;
            if (root.revertCountdown < 1) {
                root.reject();
            }
        }
    }

    contentItem: QQC2.Label {
        text: i18np("Will revert to previous configuration in %1 second.", "Will revert to previous configuration in %1 seconds.", root.revertCountdown)
        font.pixelSize: Bigscreen.Units.defaultFontPixelSize
    }
}
