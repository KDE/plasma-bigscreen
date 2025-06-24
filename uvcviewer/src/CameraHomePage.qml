/*
    SPDX-FileCopyrightText: 2025 Seshan Ravikumar <seshan@sineware.ca>
    SPDX-License-Identifier: LicenseRef-KDE-Accepted-GPL
*/
import QtQuick
import QtQuick.Layouts
import QtMultimedia
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami
import org.kde.bigscreen as Bigscreen
  
  
Kirigami.Page {
    id: homePage
    title: i18nc("@title", "Select Media Device")
    MediaDevices {
        id: mediaDevices
    }
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Kirigami.Units.largeSpacing
        ListView {
            id: cameraList
            visible: mediaDevices.videoInputs.length > 0
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: mediaDevices.videoInputs
            spacing: Kirigami.Units.smallSpacing
  
            focus: true
            focusPolicy: Qt.StrongFocus
  
            highlightMoveDuration: Kirigami.Units.longDuration
            highlightFollowsCurrentItem: true
            keyNavigationEnabled: true
            
            delegate: Bigscreen.ButtonDelegate {
                width: ListView.view.width
                
                text: modelData.description
                description: modelData.id
                icon.name: "camera-web"
                
                onClicked: {
                    selectCamera(modelData);
                }
                
                Keys.onPressed: function(event) {
                    if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
                        selectCamera(modelData);
                    }
                }
            }
        }
        Kirigami.Heading {
            visible: mediaDevices.videoInputs.length === 0
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            level: 1
            text: i18n("No video devices found")
            opacity: 0.7
        }
        Kirigami.Heading {
            level: 2
            text: i18n("Plasma Bigscreen UVC Viewer")
            Layout.alignment: Qt.AlignHCenter
            opacity: 0.7
        }
    }
    function selectCamera(cameraDevice) {
        console.log("Camera selected:", cameraDevice.description);
        cameraSelected(cameraDevice);
    }
    signal cameraSelected(var cameraDevice)
}