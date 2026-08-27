/*
    SPDX-FileCopyrightText: 2026 Cengiz Cimen <cengizcimen007@gmail.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import org.kde.plasma.workspace.dbus as DBus
import org.kde.bigscreen.shell as BigscreenShell

pragma Singleton

QtObject {
    id: navigationRumble

    enum Strength {
        Off,
        Weak,
        Medium,
        Strong
    }

    function sendRumble(lowFreq, highFreq, durationMs) {
        const pending_reply = DBus.SessionBus.asyncCall({
            service: "org.kde.plasma.bigscreen.inputhandler",
            path: "/InputHandler",
            iface: "org.kde.plasma.bigscreen.inputhandler",
            member: "sendSdlControllerRumble",
            arguments: [
                new DBus.int32(Math.round(lowFreq)),
                new DBus.int32(Math.round(highFreq)),
                new DBus.int32(durationMs)
            ]
        });

        pending_reply.finished.connect(() => {
            pending_reply.destroy();
        });
    }

    function playNavigationRumble() {
        switch (BigscreenShell.Settings.navigationRumbleIntensity) {
        case NavigationRumble.Strength.Off:
            return;
        case NavigationRumble.Strength.Weak:
            sendRumble(0, 1000, 60);
            break;
        case NavigationRumble.Strength.Medium:
            sendRumble(0, 10000, 70);
            break;
        case NavigationRumble.Strength.Strong:
            sendRumble(0, 20000, 80);
            break;
        }
    }

    function playConfirmRumble() {
        switch (BigscreenShell.Settings.navigationRumbleIntensity) {
        case NavigationRumble.Strength.Off:
            return;
        case NavigationRumble.Strength.Weak:
            sendRumble(0, 10000, 60);
            break;
        case NavigationRumble.Strength.Medium:
            sendRumble(1000, 20000, 70);
            break;
        case NavigationRumble.Strength.Strong:
            sendRumble(2000, 40000, 100);
            break;
        }
    }

    function playCancelRumble() {
        switch (BigscreenShell.Settings.navigationRumbleIntensity) {
        case NavigationRumble.Strength.Off:
            return;
        case NavigationRumble.Strength.Weak:
            sendRumble(0, 4000, 80);
            break;
        case NavigationRumble.Strength.Medium:
            sendRumble(1000, 20000, 100);
            break;
        case NavigationRumble.Strength.Strong:
            sendRumble(2000, 40000, 100);
            break;
        }
    }

    function playLoadingRumble() {
        switch (BigscreenShell.Settings.navigationRumbleIntensity) {
        case NavigationRumble.Strength.Off:
            return;
        case NavigationRumble.Strength.Weak:
            sendRumble(1000, 1000, 250);
            break;
        case NavigationRumble.Strength.Medium:
            sendRumble(2000, 2200, 350);
            break;
        case NavigationRumble.Strength.Strong:
            sendRumble(3000, 3200, 500);
            break;
        }
    }
}