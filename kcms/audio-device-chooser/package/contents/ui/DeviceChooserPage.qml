import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3 as Controls
import QtQuick.Window 2.2
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.kquickcontrolsaddons 2.0
import org.kde.kirigami 2.5 as Kirigami
import org.kde.plasma.private.volume 0.1
import org.kde.mycroft.bigscreen 1.0 as BigScreen

import "delegates" as Delegates
import "views" as Views

FocusScope {
    id: mainFlick
    anchors {
        fill: parent
        margins: Kirigami.Units.smallSpacing * 2
    }

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
        property Item currentSection
        y: currentSection ? -currentSection.y : 0
        Behavior on y {
            NumberAnimation {
                duration: Kirigami.Units.longDuration * 2
                easing.type: Easing.InOutQuad
            }
        }
        height: parent.height

        BigScreen.TileView {
            id: sinkView
            model: paSinkModel
            focus: true
            title: i18n("Playback Devices")
            currentIndex: 0
            onActiveFocusChanged: { 
                if(activeFocus){ 
                    contentLayout.currentSection = sinkView
                }
            }
            delegate: Delegates.AudioDelegate {
                isPlayback: true
                type: "sink"
            }
            navigationDown: sourceView.visible ? sourceView : kcmcloseButton
        }

        BigScreen.TileView {
            id: sourceView
            model: paSourceModel
            title: i18n("Recording Devices")
            currentIndex: 0
            focus: false
            visible: sourceView.view.count > 0 ? 1 : 0 
            onActiveFocusChanged: {
                if(activeFocus){
                    contentLayout.currentSection = sourceView
                }
            }
            delegate: Delegates.AudioDelegate {
                isPlayback: false
                type: "source"
            }
            navigationUp: sinkView
            navigationDown: kcmcloseButton
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
