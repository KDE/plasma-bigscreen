import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3 as Controls
import QtQuick.Window 2.2
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.kquickcontrolsaddons 2.0
import org.kde.kirigami 2.5 as Kirigami
import org.kde.plasma.private.volume 0.1

import "delegates" as Delegates
import "views" as Views

FocusScope {
    id: mainFlick
    anchors.fill: parent
    anchors.margins: units.smallSpacing * 2

    SourceModel {
        id: paSourceModel
    }

    SinkModel {
        id: paSinkModel
    }

    ColumnLayout {
        id: contentLayout
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: Kirigami.Units.largeSpacing
        spacing: Kirigami.Units.largeSpacing
        property RowLayout currentSection
        y: currentSection ? -currentSection.y : 10
        Behavior on y {
            //Can't be an Animator
            NumberAnimation {
                duration: Kirigami.Units.longDuration * 2
                easing.type: Easing.InOutQuad
            }
        }
        height: parent.height

        RowLayout {
            id: rLayoutPlayback
            Layout.fillHeight: true
            Layout.fillWidth: true

            Views.RowLabelView {
                id: rowLbl1
                text: qsTr("Playback Devices")
                color: sinkView.activeFocus ? Kirigami.Theme.linkColor : Kirigami.Theme.backgroundColor
            }

            Views.TileView {
                id: sinkView
                model: paSinkModel
                focus: true
                x: -currentItem.x + rowLbl1.width + Kirigami.Units.gridUnit * 1
                currentIndex: 0
                onActiveFocusChanged: if (activeFocus) contentLayout.currentSection = rLayoutPlayback
                delegate: Delegates.AudioDelegate {
                    isPlayback: true
                    anchors.verticalCenter: parent.verticalCenter
                    type: "sink"
                }
                navigationDown: sourceView
            }
        }


        RowLayout{
            id: rLayoutRecord
            Layout.fillHeight: true
            Layout.fillWidth: true

            Views.RowLabelView {
                id: rowLbl2
                text: qsTr("Recording Devices")
                color: sourceView.activeFocus ? Kirigami.Theme.linkColor : Kirigami.Theme.backgroundColor
            }

            Views.TileView {
                id: sourceView
                model: paSourceModel
                currentIndex: 0
                x: -currentItem.x + rowLbl2.width + Kirigami.Units.gridUnit * 1
                onActiveFocusChanged: if (activeFocus) contentLayout.currentSection = rLayoutRecord
                delegate: Delegates.AudioDelegate {
                    isPlayback: false
                    anchors.verticalCenter: parent.verticalCenter
                    type: "source"
                }
                navigationUp: sinkView
            }

        }

        Component.onCompleted: {
            sinkView.forceActiveFocus();
        }

        Connections {
            target: root
            onActivateDeviceView: {
                sinkView.forceActiveFocus();
            }
        }
    }
}
