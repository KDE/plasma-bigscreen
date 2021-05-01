/*
    SPDX-FileCopyrightText: 2020 Noah Davis <noahadvs@gmail.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.14
import QtMultimedia 5.14
import Qt.labs.platform 1.1

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
        if (clickedSound.playing) {
            clickedSound.stop();
        }
        if (movingSound.playing) {
            movingSound.stop();
        }
    }

    function playClickedSound() {
        clickedSound.play();
    }

    function playMovingSound() {
        movingSound.play();
    }
}
