import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3 as Controls
import QtQuick.Window 2.2
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.kquickcontrolsaddons 2.0
import org.kde.kirigami 2.5 as Kirigami

Item {
    width: gridSettingsView.cellWidth
    height: gridSettingsView.cellHeight

    ColumnLayout {
        width: gridSettingsView.cellWidth
        anchors.centerIn: parent
        Kirigami.Icon {
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            Layout.fillWidth: true
            Layout.preferredHeight: gridSettingsView.cellHeight - (root.reservedSpaceForLabel + Kirigami.Units.largeSpacing)
            source: model.icon
        }
        PlasmaComponents.Label {
            Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
            Layout.preferredWidth: Kirigami.Units.iconSizes.medium
            text: model.name
        }
    }
} 
