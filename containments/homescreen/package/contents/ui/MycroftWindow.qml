
import QtQuick 2.9
import QtQuick.Window 2.3
import Mycroft 1.0 as Mycroft

Window {
    id: window
    color: "black"
    Mycroft.SkillView {
        id: skillView
        anchors.fill: parent
        open: false
        onOpenChanged: {
            if (open) {
                window.showMaximized();
            }
        }
        //FIXME: find a better way for timeouts
        //onActiveSkillClosed: open = false;
/*
        topPadding: plasmoid.availableScreenRect.y
        bottomPadding: root.height - plasmoid.availableScreenRect.y - plasmoid.availableScreenRect.height
        leftPadding: plasmoid.availableScreenRect.x
        rightPadding: root.width - plasmoid.availableScreenRect.x - plasmoid.availableScreenRect.width
        */
    }
}
