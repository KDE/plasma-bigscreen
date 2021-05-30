/*
    SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2013-2017 Jan Grulich <jgrulich@redhat.com>

    SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL
*/

import QtQuick 2.14
import QtQuick.Layouts 1.14
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.mycroft.bigscreen 1.0 as BigScreen


PlasmaComponents.Button {
    id: button

    Layout.fillHeight: true
    Layout.preferredWidth: height

    leftPadding: 0
    topPadding: 0
    rightPadding: 0
    bottomPadding: 0

    background: PlasmaCore.FrameSvgItem {
        id: frame
        imagePath: "widgets/viewitem"
        prefix: "hover"
        colorGroup: PlasmaCore.ColorScope.colorGroup
        
        visible: button.activeFocus
    }

    contentItem: PlasmaCore.IconItem {
        id: icon
        source: button.icon.name
        colorGroup: PlasmaCore.ColorScope.colorGroup
    }

    Keys.onReturnPressed: {
        clicked();
    }

    onClicked: BigScreen.NavigationSoundEffects.playClickedSound()

    Keys.onPressed: {
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
