/*
    SPDX-FileCopyrightText: 2019 Aditya Mehra <aix.m@outlook.com>
    SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>

    SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2

import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami
import org.kde.plasma.private.volume
import org.kde.bigscreen as Bigscreen

import "delegates" as Delegates

Kirigami.ScrollablePage {
    id: root
    title: i18n("Audio Devices")

    signal activateDeviceView

    background: null
    leftPadding: Kirigami.Units.smallSpacing
    topPadding: Kirigami.Units.smallSpacing
    rightPadding: Kirigami.Units.smallSpacing
    bottomPadding: Kirigami.Units.smallSpacing

    SourceModel {
        id: paSourceModel
    }

    SinkModel {
        id: paSinkModel
    }

    onActiveFocusChanged: {
        if (activeFocus) {
            sinkView.forceActiveFocus();
        }
    }

    ColumnLayout {
        spacing: 0
        KeyNavigation.left: root.KeyNavigation.left

        QQC2.Label {
            text: i18n("Playback Devices")
            font.pixelSize: 22
            font.weight: Font.Normal
            Layout.fillWidth: true
            Layout.topMargin: Kirigami.Units.gridUnit
            Layout.bottomMargin: Kirigami.Units.gridUnit
        }

        ListView {
            id: sinkView
            Layout.fillWidth: true
            model: paSinkModel
            implicitHeight: contentHeight
            currentIndex: 0

            delegate: Delegates.AudioDelegate {
                id: delegate
                type: "sink"
                width: sinkView.width

                onClicked: {
                    audioDelegateSidebar.delegate = delegate;
                    audioDelegateSidebar.type = delegate.type;
                    audioDelegateSidebar.model = delegate.model;
                    audioDelegateSidebar.open();
                }
            }
            KeyNavigation.down: sourceView
        }

        QQC2.Label {
            text: i18n("Recording Devices")
            font.pixelSize: 22
            font.weight: Font.Normal
            Layout.fillWidth: true
            Layout.topMargin: Kirigami.Units.gridUnit
            Layout.bottomMargin: Kirigami.Units.gridUnit
        }

        ListView {
            id: sourceView
            model: paSourceModel
            Layout.fillWidth: true
            implicitHeight: contentHeight
            currentIndex: 0

            delegate: Delegates.AudioDelegate {
                id: delegate
                width: sourceView.width
                type: "source"

                onClicked: {
                    audioDelegateSidebar.delegate = delegate;
                    audioDelegateSidebar.type = delegate.type;
                    audioDelegateSidebar.model = delegate.model;
                    audioDelegateSidebar.open();
                }
            }
            KeyNavigation.up: sinkView
        }

        AudioDelegateSidebar {
            id: audioDelegateSidebar

            property var delegate
            onClosed: {
                if (delegate) {
                    delegate.forceActiveFocus();
                } else {
                    sinkView.forceActiveFocus();
                }
            }
        }
    }
}
