/*
    SPDX-FileCopyrightText: 2020 Aditya Mehra <aix.m@outlook.com>

    SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
*/

import QtQuick 2.14
import QtQuick.Layouts 1.14
import QtQuick.Controls 2.14
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.kirigami 2.12 as Kirigami

Item {
    id: hdmiCecConfig
    Layout.fillWidth: true
    Layout.fillHeight: true

    onFocusChanged: {
        if(focus) {
            buttonMapRepeater.forceActiveFocus()
        }
    }

    Connections {
        target: kcm
        onCecConfigChanged: {
            if(button == "ButtonLeft"){
                buttonLeftConfigValue.text = kcm.getCecKeyConfig("ButtonLeft")
            }
            if(button == "ButtonRight"){
                buttonRightConfigValue.text = kcm.getCecKeyConfig("ButtonRight")
            }
            if(button == "ButtonUp"){
                buttonUpConfigValue.text = kcm.getCecKeyConfig("ButtonUp")
            }
            if(button == "ButtonDown"){
                buttonDownConfigValue.text = kcm.getCecKeyConfig("ButtonDown")
            }
            if(button == "ButtonEnter"){
                buttonEnterConfigValue.text = kcm.getCecKeyConfig("ButtonEnter")
            }
            if(button == "ButtonBack"){
                buttonBackConfigValue.text = kcm.getCecKeyConfig("ButtonBack")
            }
            if(button == "ButtonHomepage"){
                buttonHomepageConfigValue.text = kcm.getCecKeyConfig("ButtonHomepage")
            }
        }
    }

    ListModel {
        id: buttonMapModel
        ListElement {buttonDisplay: "Button Left"; buttonType: "ButtonLeft"}
        ListElement {buttonDisplay: "Button Right"; buttonType: "ButtonRight"}
        ListElement {buttonDisplay: "Button Up"; buttonType: "ButtonUp"}
        ListElement {buttonDisplay: "Button Down"; buttonType: "ButtonDown"}
        ListElement {buttonDisplay: "Button Ok/Select"; buttonType: "ButtonEnter"}
        ListElement {buttonDisplay: "Button Back"; buttonType: "ButtonBack"}
        ListElement {buttonDisplay: "Button Home"; buttonType: "ButtonHomepage"}
    }

    ColumnLayout {
        anchors.fill: parent

        Kirigami.Heading {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            text: i18n("Setup CEC Keymap")
        }

        Item {
            Layout.preferredHeight: Kirigami.Units.gridUnit
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ListView {
                id: buttonMapRepeater
                anchors.fill: parent
                model:buttonMapModel
                keyNavigationEnabled: true
                highlightFollowsCurrentItem: true
                spacing: Kirigami.Units.smallSpacing
                delegate: MapButton {
                    id: mapButtonType
                }
            }
        }
    }
} 
