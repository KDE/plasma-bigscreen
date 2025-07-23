// SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2

import org.kde.kirigami as Kirigami
import org.kde.bigscreen as Bigscreen

ColumnLayout {
    id: root

    /*!
       \brief This property holds the title to display on the header.
     */
    property string title

    /*!
       \brief This property holds the subtitle to display on the header.
     */
    property string subtitle

    /*!
       \brief This property holds the icon to display on the header.
     */
    property alias iconSource: headerIcon.source

    spacing: Kirigami.Units.gridUnit

    Item { Layout.fillHeight: true }

    Kirigami.Icon {
        id: headerIcon

        Layout.alignment: Qt.AlignHCenter
        implicitWidth: 96
        implicitHeight: 96
    }

    QQC2.Label {
        id: titleLabel
        visible: text.length > 0

        Layout.fillWidth: true
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        maximumLineCount: 2
        elide: Text.ElideRight
        text: root.title
        font.pixelSize: 32
        font.weight: Font.Light
    }

    QQC2.Label {
        id: subtitleLabel
        visible: text.length > 0

        Layout.fillWidth: true
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        maximumLineCount: 2
        elide: Text.ElideRight
        text: root.subtitle
        font.pixelSize: Bigscreen.Units.defaultFontPixelSize
        font.weight: Font.Light
    }
}
