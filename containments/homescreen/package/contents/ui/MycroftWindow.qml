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

Window {
    id: window
    color: Qt.rgba(0, 0, 0, 0.8)

    width: screen.availableGeometry.width
    height: screen.availableGeometry.height

    Timer {
        interval: 10000
        running: Mycroft.MycroftController.status != Mycroft.MycroftController.Open
        onTriggered: {
            print("Trying to connect to Mycroft");
            Mycroft.MycroftController.start();
        }
    }
    onVisibleChanged: {
        skillView.open = visible;
    }

    Mycroft.StatusIndicator {
        id: si
        z: 2
        anchors {
            right: parent.right
            top: parent.top
            margins: Kirigami.Units.largeSpacing
            topMargin: Kirigami.Units.largeSpacing + plasmoid.availableScreenRect.y
        }
    }
    Kirigami.Heading {
        id: inputQuery
        Kirigami.Theme.colorSet: mainView.Kirigami.Theme.colorSet
        anchors.right: si.left
        anchors.rightMargin: Kirigami.Units.largeSpacing
        anchors.verticalCenter: si.verticalCenter
        level: 3
        opacity: 0
        onTextChanged: {
            opacity = 1;
            utteranceTimer.restart();
        }
        Timer {
            id: utteranceTimer
            interval: 3000
            onTriggered: {
                inputQuery.text = "";
                inputQuery.opacity = 0
            }
        }
        Behavior on opacity {
            OpacityAnimator {
                duration: Kirigami.units.longDuration
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
        }
    }
        
    Mycroft.SkillView {
        id: skillView
        anchors.fill: parent
        open: false
        Keys.onEscapePressed: window.visible = false;
        KeyNavigation.up: closeButton
        activeSkills.blackList: ["youtube-skill.aiix"]
        activeSkills.onBlacklistedSkillActivated: {
            plasmoid.nativeInterface.executeCommand("mycroft-gui-app --hideTextInput --skill=" + skillId);
        }
       // activeSkills.onSkillActivated: window.showMaximized();

        onOpenChanged: {
            if (open) {
                window.showMaximized();
            } else {
                window.visible = false;
            }
        }
        
        Rectangle {
            id: closeButton
            anchors.top: parent.top
            anchors.left: parent.left
            width: Kirigami.Units.iconSizes.huge
            height: Kirigami.Units.iconSizes.huge
            opacity: focus ? 1 : 0
            color: focus ? Kirigami.Theme.highlightColor :"transparent"
            
            onFocusChanged: {
                if(focus){
                    skillView.currentItem.contentItem.focus = false;
                }
            }

            Keys.onDownPressed: {
                skillView.currentItem.contentItem.forceActiveFocus()
            }
            
            Kirigami.Icon {
                anchors.centerIn: parent
                width: Kirigami.Units.iconSizes.large
                height: Kirigami.Units.iconSizes.large
                source: "tab-close"
            }
            
            Keys.onReturnPressed: {
                window.visible = false;
            }
            
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    window.visible = false;
                }
            }
        }
    }
    
        //FIXME: find a better way for timeouts
        //onActiveSkillClosed: open = false;
/*
        topPadding: plasmoid.availableScreenRect.y
        bottomPadding: root.height - plasmoid.availableScreenRect.y - plasmoid.availableScreenRect.height
        leftPadding: plasmoid.availableScreenRect.x
        rightPadding: root.width - plasmoid.availableScreenRect.x - plasmoid.availableScreenRect.width
        */
}
