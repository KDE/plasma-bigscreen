/*
    SPDX-FileCopyrightText: 2019 Aditya Mehra <aix.m@outlook.com>

    SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
*/

import QtQuick 2.14
import QtQuick.Layouts 1.14
import org.kde.kirigami 2.12 as Kirigami
import QtQuick.Controls 2.14
import org.kde.plasma.core 2.1 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.private.volume 0.1
import QtQuick.Window 2.14
import org.kde.kcm 1.1 as KCM

import "delegates" as Delegates
import "views" as Views

KCM.SimpleKCM {
    id: root
    title: i18n("Audio Device Chooser")
    
    signal activateDeviceView

    background: null
    leftPadding: Kirigami.Units.smallSpacing
    topPadding: 0
    rightPadding: Kirigami.Units.smallSpacing
    bottomPadding: 0
    
    Component.onCompleted: {
        root.activateDeviceView
    }
    
    footer: Button {
        id: kcmcloseButton
        implicitHeight: Kirigami.Units.gridUnit * 2
        anchors.left: parent.left
        anchors.right: parent.right
        
        background: Rectangle {
            color: kcmcloseButton.activeFocus ? Kirigami.Theme.highlightColor : Kirigami.Theme.backgroundColor
        }
        
        contentItem: Item {
            RowLayout {
                anchors.centerIn: parent
                Kirigami.Icon {
                    Layout.preferredWidth: Kirigami.Units.iconSizes.small
                    Layout.preferredHeight: Kirigami.Units.iconSizes.small
                    source: "window-close"
                }
                Label {
                    text: i18n("Exit")
                }
            }
        } 

        Keys.onUpPressed: root.activateDeviceView()
        
        onClicked: {
            Window.window.close()
        }
        
        Keys.onReturnPressed: {
            Window.window.close()
        }
    }

    contentItem: DeviceChooserPage {
        id: deviceChooserView
    }
}
