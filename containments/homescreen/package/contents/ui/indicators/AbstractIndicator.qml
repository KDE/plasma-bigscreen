/*
    SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2013-2017 Jan Grulich <jgrulich@redhat.com>

    SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL
*/

import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents
import org.kde.bigscreen as BigScreen
import org.kde.kirigami as Kirigami
import org.kde.ksvg as KSvg

PlasmaComponents.Button {
    id: button

    Layout.fillHeight: true
    Layout.preferredWidth: height

    leftPadding: 0
    topPadding: 0
    rightPadding: 0
    bottomPadding: 0

    background: KSvg.FrameSvgItem {
        id: frame
        imagePath: "widgets/viewitem"
        prefix: "hover"
        visible: button.activeFocus
    }

    contentItem: Kirigami.Icon {
        id: icon
        source: button.icon.name
    }

    Keys.onReturnPressed: (event)=> {
        clicked();
    }

    onClicked: (event)=> {
        BigScreen.NavigationSoundEffects.playClickedSound()
    }

    Keys.onPressed: (event)=> {
        switch (event.key) {
            case Qt.Key_Down:
            case Qt.Key_Right:
            case Qt.Key_Left:
            case Qt.Key_Tab:
            case Qt.Key_Backtab:
                BigScreen.NavigationSoundEffects.playMovingSound();
                break;
            default:
                break;
        }
    }
}
