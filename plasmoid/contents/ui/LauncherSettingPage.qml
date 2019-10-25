import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3 as Controls
import QtQuick.Window 2.2
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.kquickcontrolsaddons 2.0
import org.kde.kirigami 2.5 as Kirigami

Rectangle {
    anchors.fill: parent
    color: Kirigami.Theme.backgroundColor
    anchors.topMargin: Kirigami.Units.gridUnit * 10
    anchors.bottomMargin: Kirigami.Units.gridUnit * 10

    Item {
        width: parent.width
        height: parent.height

        GridView {
            id: gridSettingsView
            layoutDirection: Qt.LeftToRight
            width: parent.width
            height: parent.height
            flow: GridView.FlowTopToBottom
            cellWidth: gridSettingsView.width / 3
            cellHeight: gridSettingsView.height / 1
            clip: true
            model: ListModel {
                ListElement { name: "Wireless"; icon: "network-wireless-connected-100"}
                ListElement { name: "Preferences"; icon: "dialog-scripts"}
                ListElement { name: "Mycroft"; icon: "mycroft"}
            }
            delegate: RowSettingsDelegate{}
        }
    }
}
