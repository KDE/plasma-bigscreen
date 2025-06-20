
/*
    SPDX-FileCopyrightText: 2025 Seshan Ravikumar <seshan@sineware.ca>
    SPDX-License-Identifier: LicenseRef-KDE-Accepted-GPL
*/
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami

Kirigami.ApplicationWindow {
    id: root

    width: 1280 
    height: 720

    title: i18nc("@title:window", "Bigscreen UVC Viewer")

    pageStack.initialPage: CameraHomePage {
        onCameraSelected: function(cameraDevice) {
            pageStack.layers.push(Qt.resolvedUrl('./UvcViewer.qml'));
        }
    }
}
