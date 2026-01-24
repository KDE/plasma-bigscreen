/*
    SPDX-FileCopyrightText: 2020 Noah Davis <noahadvs@gmail.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtMultimedia
import Qt.labs.platform

import org.kde.bigscreen.shell as BigscreenShell

pragma Singleton

QtObject {
    id: navigationSoundEffects

    property SoundEffect clickedSound: SoundEffect {
        source: StandardPaths.locate(StandardPaths.GenericDataLocation, "sounds/plasma-bigscreen/clicked.wav")
    }

    property SoundEffect movingSound: SoundEffect {
        source: StandardPaths.locate(StandardPaths.GenericDataLocation, "sounds/plasma-bigscreen/moving.wav")
    }

    function stopNavigationSounds() {
        if (!BigscreenShell.Settings.navigationSoundEnabled) {
            return;
        }
        if (clickedSound.playing) {
            clickedSound.stop();
        }
        if (movingSound.playing) {
            movingSound.stop();
        }
    }

    function playClickedSound() {
        if (!BigscreenShell.Settings.navigationSoundEnabled) {
            return;
        }
        clickedSound.play();
    }

    function playMovingSound() {
        if (!BigscreenShell.Settings.navigationSoundEnabled) {
            return;
        }
        movingSound.play();
    }
}
