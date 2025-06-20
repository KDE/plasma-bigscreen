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
    id: cameraViewer
    
    padding: 0
    globalToolBarStyle: Kirigami.ApplicationHeaderStyle.None
    
    focus: true
    
    background: Rectangle {
        color: "black"
    }
    
    property var selectedCamera: null
    
    MediaDevices {
        id: mediaDevices
    }
    
    CaptureSession {
        id: captureSession
        camera: Camera {
            id: camera
            cameraDevice: cameraViewer.selectedCamera || mediaDevices.defaultVideoInput
            active: true
        }
        videoOutput: uvcVideoOutput
    }
    
    VideoOutput {
        id: uvcVideoOutput
        anchors.fill: parent
        fillMode: VideoOutput.PreserveAspectCrop
    }
    
    Keys.onPressed: function(event) {
        if (event.key === Qt.Key_Escape) {
            pageStack.layers.pop();
        }
    }
    
    Component.onCompleted: {
        // Ensure the page has focus for keyboard events
        forceActiveFocus();
        console.log("Camera viewer loaded with device:", 
                   cameraViewer.selectedCamera ? cameraViewer.selectedCamera.description : "default");
    }
}