import QtQuick 2.9
import Mycroft 1.0 as Mycroft

Item {
    function sendText(utterance) {
         Mycroft.MycroftController.sendText(utterance)
    }

    Component.onCompleted: Mycroft.MycroftController.start()
}
