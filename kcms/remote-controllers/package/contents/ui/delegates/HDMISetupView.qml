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
    signal updateKeyValue(string targetname, int value)


    onFocusChanged: {
        if(focus) {
            buttonMapRepeater.forceActiveFocus()
        }
    }

    Connections {
        target: kcm
        onCecConfigChanged: {
            if(button == "ButtonLeft"){
                updateKeyValue("buttonLeftConfigValue", kcm.getCecKeyConfig("ButtonLeft"))
            }
            if(button == "ButtonRight"){
                updateKeyValue("buttonRightConfigValue", kcm.getCecKeyConfig("ButtonRight"))
            }
            if(button == "ButtonUp"){
                updateKeyValue("buttonUpConfigValue", kcm.getCecKeyConfig("ButtonUp"))
            }
            if(button == "ButtonDown"){
                updateKeyValue("buttonDownConfigValue", kcm.getCecKeyConfig("ButtonDown"))
            }
            if(button == "ButtonEnter"){
                updateKeyValue("buttonEnterConfigValue", kcm.getCecKeyConfig("ButtonEnter"))
            }
            if(button == "ButtonBack"){
                updateKeyValue("buttonBackConfigValue", kcm.getCecKeyConfig("ButtonBack"))
            }
            if(button == "ButtonHomepage"){
                updateKeyValue("buttonHomepageConfigValue", kcm.getCecKeyConfig("ButtonHomepage"))
            }
        }
    }

    ListModel {
        id: buttonMapModel
        ListElement {buttonDisplay: "Button Left"; buttonType: "ButtonLeft"; objectName: "buttonLeftConfigValue"}
        ListElement {buttonDisplay: "Button Right"; buttonType: "ButtonRight"; objectName: "buttonRightConfigValue"}
        ListElement {buttonDisplay: "Button Up"; buttonType: "ButtonUp"; objectName: "buttonUpConfigValue"}
        ListElement {buttonDisplay: "Button Down"; buttonType: "ButtonDown"; objectName: "buttonDownConfigValue"}
        ListElement {buttonDisplay: "Button Ok/Select"; buttonType: "ButtonEnter"; objectName: "buttonEnterConfigValue"}
        ListElement {buttonDisplay: "Button Back"; buttonType: "ButtonBack"; objectName: "buttonBackConfigValue"}
        ListElement {buttonDisplay: "Button Home"; buttonType: "ButtonHomepage"; objectName: "buttonHomepageConfigValue"}
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
                    objectName: model.objectName
                }
            }
        }
    }
}
