/*
    Copyright 2013-2017 Jan Grulich <jgrulich@redhat.com>

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) version 3, or any
    later version accepted by the membership of KDE e.V. (or its
    successor approved by the membership of KDE e.V.), which shall
    act as a proxy defined in Section 6 of version 3 of the license.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with this library.  If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.9
import org.kde.kcoreaddons 1.0 as KCoreAddons
import org.kde.kquickcontrolsaddons 2.0 as KQuickControlsAddons
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.kirigami 2.11 as Kirigami

Item {
    property real rxBytes: 0
    property real txBytes: 0
    property alias interval: timer.interval
    property var units: Kirigami.Units

    height: visible ? plotter.height + plotter.anchors.topMargin + units.smallSpacing : 0

    Repeater {
        id: labels
        model: 6
        readonly property int labelHeight: theme.mSize(theme.smallestFont).height

        PlasmaComponents.Label {
            anchors {
                right: plotter.left
                top: parent.top
                rightMargin: units.smallSpacing
                topMargin: Math.round(index * plotter.height / 5)
            }
            // Workaround to get paintedHeight. (Undefined or paintedheight does not work.)
            height: labels.labelHeight
            font.pointSize: theme.smallestFont.pointSize
            lineHeight: 1.75
            text: KCoreAddons.Format.formatByteSize(plotter.maxValue * (1 - index / 5)) + i18n("/s")
        }
    }

    KQuickControlsAddons.Plotter {
        id: plotter
        property variant downloadColor: theme.highlightColor
        property variant uploadColor: Qt.hsva((downloadColor.hsvHue + 0.5) % 1, downloadColor.hsvSaturation, downloadColor.hsvValue, downloadColor.a)
        // Joining two QList<foo> in QML/javascript doesn't seem to work so I'm getting maximum from both list separately
        readonly property int maxValue: Math.max(Math.max.apply(null, downloadPlotData.values), Math.max.apply(null, uploadPlotData.values))
        anchors {
            left: parent.left
            leftMargin: units.gridUnit * 3
            right: parent.right
            top: parent.top
            // Align plotter lines with labels.
            topMargin: Math.round(labels.labelHeight / 2)
        }
        width: units.gridUnit * 20
        height: units.gridUnit * 8
        horizontalGridLineCount: 5

        dataSets: [
            KQuickControlsAddons.PlotData {
                id: downloadPlotData
                label: i18n("Download")
                color: plotter.downloadColor
            },
            KQuickControlsAddons.PlotData {
                id: uploadPlotData
                label: i18n("Upload")
                color: plotter.uploadColor
            }
        ]

        Timer {
            id: timer
            repeat: true
            running: parent.visible
            property real prevRxBytes
            property real prevTxBytes
            Component.onCompleted: {
                prevRxBytes = rxBytes
                prevTxBytes = txBytes
            }
            onTriggered: {
                var rxSpeed = (rxBytes - prevRxBytes) * 1000 / interval
                var txSpeed = (txBytes - prevTxBytes) * 1000 / interval
                prevRxBytes = rxBytes
                prevTxBytes = txBytes
                plotter.addSample([rxSpeed, txSpeed]);
            }
        }
    }
}
 
