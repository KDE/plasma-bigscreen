/*
    SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2019 Aditya Mehra <aix.m@outlook.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.14
import QtQuick.Window 2.14
import QtQuick.Layouts 1.14
import QtQuick.Controls 2.14 as Controls
import org.kde.kirigami 2.12 as Kirigami
import org.kde.plasma.core 2.0 as PlasmaCore
import Mycroft 1.0 as Mycroft

Window {
    id: window
    color: Qt.rgba(0, 0, 0, 0.8)

    width: screen.availableGeometry.width
    height: screen.availableGeometry.height

    Component.onCompleted: Mycroft.MycroftController.start()

    function disconnectclose() {
        Mycroft.MycroftController.disconnectSocket();
        window.close();
        mycroftWindowLoader.active = false;
    }

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
            interval: 8000
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
            
            onSkillTimeoutReceived: {
                if(skillView.currentItem.contentItem.skillId() == skillidleid) {
                    window.close()
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
        activeSkills.blackList: plasmoid.nativeInterface.applicationListModel.voiceAppSkills

        activeSkills.onBlacklistedSkillActivated: {
            plasmoid.nativeInterface.executeCommand("mycroft-gui-app --hideTextInput --skill=" + skillId);
        }
       // activeSkills.onSkillActivated: window.showMaximized();
        activeSkills.onActiveIndexChanged: {
            if (activeSkills.activeIndex > 0) {
                window.visible = false;
            }
        }

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
            width: PlasmaCore.Units.iconSizes.huge
            height: PlasmaCore.Units.iconSizes.huge
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
                width: PlasmaCore.Units.iconSizes.large
                height: PlasmaCore.Units.iconSizes.large
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
