/*
    SPDX-FileCopyrightText: 2025 Seshan Ravikumar <seshan@sineware.ca>
    SPDX-License-Identifier: LicenseRef-KDE-Accepted-GPL
*/
import QtQuick
import QtQuick.Layouts
import QtMultimedia
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami

Kirigami.Page {
    id: homePage
    
    title: i18nc("@title", "Select Media Device")
    
    MediaDevices {
        id: mediaDevices
    }
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Kirigami.Units.largeSpacing
        
        Kirigami.Heading {
            text: i18nc("@title", "Available Video Inputs")
            level: 2
            Layout.alignment: Qt.AlignHCenter
        }
        
        GridView {
            id: cameraGrid
            
            Layout.fillWidth: true
            Layout.fillHeight: true
            
            model: mediaDevices.videoInputs
            
            cellWidth: Kirigami.Units.gridUnit * 12
            cellHeight: Kirigami.Units.gridUnit * 12

            focus: true
            focusPolicy: Qt.StrongFocus

            highlight: Rectangle {
                    color: Kirigami.Theme.highlightColor
                    opacity: 0.3
                    radius: Kirigami.Units.cornerRadius
                    z: 2
                }
            highlightMoveDuration: Kirigami.Units.longDuration
            highlightFollowsCurrentItem: true
            keyNavigationEnabled: true
            
            Component {
                id: videoInputDelegate
                Kirigami.AbstractCard {
                    implicitHeight: Kirigami.Units.gridUnit * 11
                    implicitWidth: Kirigami.Units.gridUnit * 11
                    header: Kirigami.Heading {
                        text: modelData.description
                        level: 2
                    }
                    contentItem: Controls.Label {
                        wrapMode: Text.WordWrap
                        text: modelData.id
                    }
                    Kirigami.Icon {
                        source: "camera-web"
                        anchors.centerIn: parent
                        implicitHeight: Kirigami.Units.iconSizes.huge
                        implicitWidth: Kirigami.Units.iconSizes.huge
                    }

                    onPressed: {
                        selectCamera(modelData);
                    }

                    Keys.onPressed: function(event) {
                        if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
                            selectCamera(modelData);
                            event.accepted = true;
                        } else {
                            event.accepted = false;
                        }
                    }

                }
            }
            delegate: videoInputDelegate

        }
        
        Controls.Label {
            visible: mediaDevices.videoInputs.length === 0
            text: i18n("No cameras found")
            Layout.alignment: Qt.AlignHCenter
            font.pointSize: Kirigami.Theme.defaultFont.pointSize * 1.2
            opacity: 0.7
        }
        
        Controls.Label {
            visible: mediaDevices.videoInputs.length > 0
            text: i18n("Plasma Bigscreen UVC Viewer")
            Layout.alignment: Qt.AlignHCenter
            opacity: 0.7
            font.pointSize: Kirigami.Theme.smallFont.pointSize
        }
    }
    
    function selectCamera(cameraDevice) {
        console.log("Camera selected:", cameraDevice.description);
        cameraSelected(cameraDevice);
    }
    signal cameraSelected(var cameraDevice)
}