/*
    SPDX-FileCopyrightText: 2019 Aditya Mehra <aix.m@outlook.com>
    SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2

import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.extras as PlasmaExtras
import org.kde.kirigami as Kirigami
import org.kde.bigscreen as Bigscreen
import org.kde.plasma.private.volume

import "delegates" as Delegates
import "code/icon.js" as Icon

Bigscreen.SidebarOverlay {
    id: root

    property var model: null

    property string type
    readonly property bool isPlayback: type.substring(0, 4) == "sink"
    readonly property var currentPort: model ? model.Ports[model.ActivePortIndex] : null
    readonly property ListView listView: ListView.view

    openFocusItem: (model && model.PulseObject.default) ? volObj : setDefBtn

    header: ColumnLayout {
        spacing: Kirigami.Units.gridUnit

        Item { Layout.fillHeight: true }
        Kirigami.Icon {
            Layout.alignment: Qt.AlignHCenter
            implicitWidth: 96
            implicitHeight: 96
            source: model ? Icon.name(model.Volume, model.Muted, isPlayback ? "audio-volume" : "microphone-sensitivity") : ''
        }
        QQC2.Label {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            maximumLineCount: 2
            elide: Text.ElideRight
            text: currentPort ? currentPort.description : ''
            font.pixelSize: 32
            font.weight: Font.Light
        }

        QQC2.Label {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            maximumLineCount: 2
            elide: Text.ElideRight
            text: model ? model.Description : ''
            font.pixelSize: Bigscreen.Units.defaultFontPixelSize
            font.weight: Font.Light
        }
    }

    content: ColumnLayout {
        spacing: Kirigami.Units.smallSpacing

        Keys.onLeftPressed: root.close()

        Bigscreen.SwitchDelegate {
            id: setDefBtn

            KeyNavigation.down: volObj
            text: i18n('Set as default device')

            enabled: root.model && !root.model.PulseObject.default

            // HACK: setting checked binding directly doesn't seem to work
            Connections {
                target: root
                onOpened: {
                    setDefBtn.checked = root.model && root.model.PulseObject.default;
                }
            }

            onClicked: {
                if (root.model) {
                    root.model.PulseObject.default = true;
                    volObj.forceActiveFocus();
                }
            }
        }

        Delegates.VolumeObject {
            id: volObj
            model: root.model
            Layout.fillWidth: true

            Keys.onRightPressed: {
                increaseVal()
            }
            Keys.onLeftPressed: {
                decreaseVal()
            }

            Keys.onDownPressed: {
                backBtnSettingsItem.forceActiveFocus()
            }
        }

        Item { Layout.fillHeight: true }
    }
}

