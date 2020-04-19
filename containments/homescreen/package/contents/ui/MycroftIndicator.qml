/*
 * Copyright 2019 Marco Martin <mart@kde.org>
 * Copyright 2019 Aditya Mehra <aix.m@outlook.com>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  2.010-1301, USA.
 */

import QtQuick 2.9
import QtQuick.Window 2.3
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2 as Controls
import org.kde.kirigami 2.11 as Kirigami
import Mycroft 1.0 as Mycroft

RowLayout {
    Kirigami.Heading {
        id: inputQuery
        level: 3
        opacity: 0
        onTextChanged: {
            opacity = 1;
            utteranceTimer.restart();
        }
        Timer {
            id: utteranceTimer
            interval: 8000
            onTriggered: {
                inputQuery.text = "";
                inputQuery.opacity = 0
            }
        }
        Behavior on opacity {
            OpacityAnimator {
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InOutQuad
            }
        }

        Connections {
            target: Mycroft.MycroftController
            onIntentRecevied: {
                if(type == "recognizer_loop:utterance") {
                    inputQuery.text = data.utterances[0]
                }
            }
            onServerReadyChanged: {
                if (Mycroft.MycroftController.serverReady) {
                    inputQuery.text = "";
                } else {
                    inputQuery.text = i18n("Getting Ready... Please Wait");
                    utteranceTimer.running = false;
                }
            }
            onStatusChanged: {
                switch (Mycroft.MycroftController.status) {
                case Mycroft.MycroftController.Connecting:
                case Mycroft.MycroftController.Error:
                case Mycroft.MycroftController.Stopped:
                    inputQuery.text = i18n("Getting Ready... Please Wait");
                    utteranceTimer.running = false;
                    break;
                default:
                    if (Mycroft.MycroftController.serverReady) {
                        inputQuery.text = "";
                    }
                    break;
                }

            }
        }
    }
    Mycroft.StatusIndicator {
        id: si
        z: 2
        Layout.preferredWidth: height
        Layout.fillHeight: true
        hasShadow: false
    }
}
