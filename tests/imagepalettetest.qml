
import QtQuick 2.12
import QtQuick.Layouts 1.4
import QtQuick.Controls 2.12 as Controls
import org.kde.kirigami 2.10 as Kirigami
import org.kde.mycroft.bigscreen 1.0 as BigScreen

RowLayout {
    id: root
    width: 500
    height: 500

    property var icons: ["desktop", "firefox", "vlc", "applications-games", "blinken", "view-left-close", "adjustlevels", "adjustrgb", "cuttlefish"]
    property int i: 0
    BigScreen.ImagePalette {
        id: palette
        sourceItem: icon
    }
    BigScreen.ImagePalette {
        id: imgPalette
        sourceItem: image
    }
    ColumnLayout {
        Kirigami.Icon {
            id: icon
            Layout.preferredWidth: 128
            Layout.preferredHeight:128
            source: "desktop"
        }
        Controls.Button {
            text: "Next"
            onClicked: {
                i = (i+1)%icons.length
                icon.source = icons[i]
                palette.update()
            }
        }

        Repeater {
            model: palette.palette
            delegate: Rectangle {
                implicitWidth: 10 + 300 * modelData.ratio
                implicitHeight: 30
                color: modelData.color
            }
        }
    }
    Image {
        id: image
        source: "https://source.unsplash.com/random"
        Layout.preferredWidth: 500
        Layout.preferredHeight: 500/(sourceSize.width/sourceSize.height)
        ColumnLayout {
            Controls.Button {
                text: "Grab"
                onClicked: {
                    imgPalette.update()
                }
            }
            Repeater {
                model: imgPalette.palette
                delegate: Rectangle {
                    implicitWidth: 10 + 300 * modelData.ratio
                    implicitHeight: 30
                    color: modelData.color
                }
            }
        }
    }
}
