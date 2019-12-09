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
import QtQuick.VirtualKeyboard 2.2

InputPanel {
    id: inputPanel
    active:  Qt.inputMethod.visible
    visible: active
    width: parent.width

    onHeightChanged: resizeKeyboard();
    onWidthChanged: resizeKeyboard();
    function resizeKeyboard() {
        keyboard.style.keyboardDesignWidth = width*3
        keyboard.style.keyboardDesignHeight = height*3
    }
    Component.onCompleted: resizeKeyboard()
}
