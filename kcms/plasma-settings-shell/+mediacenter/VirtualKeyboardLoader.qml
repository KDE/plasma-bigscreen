/*
 *  Copyright 2019 Marco Martin <mart@kde.org>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

import QtQuick 2.6
import org.kde.kirigami 2.5 as Kirigami

Loader {
        id: inputPanel
        z: 1000
        state: "hidden"
        readonly property bool keyboardActive: item ? item.active : false
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            //HACK since the screen real estate is so small, enlarge the keyboard to remove all its internal padding
            margins: -Kirigami.Units.gridUnit
        }
        function showHide() {
            state = state == "hidden" ? "visible" : "hidden";
        }
        Component.onCompleted: inputPanel.source = "./VirtualKeyboard.qml"
        onKeyboardActiveChanged: {
            if (keyboardActive) {
                state = "visible";
            } else {
                state = "hidden";
            }
        }
        height: Math.min(parent.height / 2, Math.max(parent.height/3, Kirigami.Units.gridUnit * 15))
        states: [
            State {
                name: "visible"
                PropertyChanges {
                    target: inputPanel
                    y: inputPanel.parent.height - inputPanel.height +  Kirigami.Units.gridUnit
                    opacity: 1
                }
            },
            State {
                name: "hidden"
                PropertyChanges {
                    target: inputPanel
                    y: inputPanel.parent.height - inputPanel.parent.height/4
                    opacity: 0
                }
            }
        ]
        transitions: [
            Transition {
                from: "hidden"
                to: "visible"
                SequentialAnimation {
                    ScriptAction {
                        script: {
                            Qt.inputMethod.show();
                        }
                    }
                    ParallelAnimation {
                        NumberAnimation {
                            target: inputPanel
                            property: "y"
                            duration: units.longDuration
                            easing.type: Easing.OutQuad
                        }
                        OpacityAnimator {
                            target: inputPanel
                            duration: units.longDuration
                            easing.type: Easing.OutQuad
                        }
                    }
                }
            },
            Transition {
                from: "visible"
                to: "hidden"
                SequentialAnimation {
                    ParallelAnimation {
                        NumberAnimation {
                            target: inputPanel
                            property: "y"
                            duration: units.longDuration
                            easing.type: Easing.InQuad
                        }
                        OpacityAnimator {
                            target: inputPanel
                            duration: units.longDuration
                            easing.type: Easing.InQuad
                        }
                    }
                    ScriptAction {
                        script: {
                            Qt.inputMethod.hide();
                        }
                    }
                }
            }
        ]
    }
