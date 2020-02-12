
import QtQuick 2.12
import QtQuick.Layouts 1.4
import QtQuick.Controls 2.12 as Controls
import org.kde.kirigami 2.10 as Kirigami
import org.kde.mycroft.bigscreen 1.0 as BigScreen

Item {
    width: 500
    height: 500

    BigScreen.ImagePalette {
        id: palette
        sourceItem: icon
    }
    ColumnLayout {
        Kirigami.Icon {
            id: icon
            Layout.preferredWidth: 128
            Layout.preferredHeight:128
            source: "desktop"
        }
        Controls.Button {
            text: "grab"
            onClicked: palette.update()
        }
        Repeater {
            model: palette.palette
            delegate: Rectangle {
                implicitWidth: 30
                implicitHeight: 30
                color: modelData
            }
        }
    }
}
