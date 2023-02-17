/*
    SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2019 Aditya Mehra <aix.m@outlook.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Layouts 1.14
import QtQuick.Controls 2.15 as Controls
import org.kde.kirigami 2.19 as Kirigami
import Mycroft 1.0 as Mycroft

RowLayout {
    id: mycroftStatusIndicator

    function disconnectclose() {
        Mycroft.MycroftController.disconnectSocket();
        mycroftIndicatorLoader.active = false;
    }

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
            function onIntentRecevied(type, data) {
                if(type == "recognizer_loop:utterance") {
                    inputQuery.text = data.utterances[0]
                }
            }
            function onServerReadyChanged() {
                if (Mycroft.MycroftController.serverReady) {
                    inputQuery.text = "";
                } else {
                    inputQuery.text = i18n("Getting Ready... Please Wait");
                    utteranceTimer.running = false;
                }
            }
            function onStatusChanged(status) {
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
