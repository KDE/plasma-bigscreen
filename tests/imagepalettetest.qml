
import QtQuick 2.12
import QtQuick.Layouts 1.4
import QtQuick.Controls 2.12 as Controls
import org.kde.kirigami 2.10 as Kirigami
import org.kde.mycroft.bigscreen 1.0 as BigScreen

GridView {
    id: root
    width: 500
    height: 500

    model: ["desktop", "firefox", "vlc", "blender", "applications-games", "blinken", "view-left-close", "adjustlevels", "adjustrgb", "cuttlefish", "folder-games", "applications-network", "applications-utilities", "multimedia-player", "accessories-dictionary", "calligraflow", "calligrakrita", "calligraauthor"]

    delegate: Rectangle{
        width: 300
        height width/1.6
        color: palette.palette[0].complementary
        BigScreen.ImagePalette {
            id: palette
            sourceItem: icon
        }
        Kirigami.Icon {
            id: icon
            anchors.centerIn: parent
            width: 128
            height: 128
            source: "desktop"
        }
    }
    BigScreen.ImagePalette {
        id: palette
        sourceItem: icon
    }
    BigScreen.ImagePalette {
        id: imgPalette
        sourceItem: image
    }

    ColumnLayout {
        Rectangle {
            Layout.preferredWidth: 200
            Layout.preferredHeight: 200
            z: -1
            color: palette.palette[0].complementary
            Kirigami.Icon {
                id: icon
                anchors.centerIn: parent
                width: 128
                height: 128
                source: "desktop"
            }
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
            delegate: RowLayout {
                Layout.fillWidth: true
                Rectangle {
                    implicitWidth: 10 + 300 * modelData.ratio
                    implicitHeight: 30
                    color: modelData.color
                }
                Item {
                    Layout.fillWidth: true
                }
                Rectangle {
                    implicitWidth: 30
                    implicitHeight: 30
                    color: modelData.complementary
                }
            }
        }
    }
    Item {
        Layout.preferredWidth: 500
        Layout.preferredHeight: 500/(image.sourceSize.width/image.sourceSize.height)
        Image {
            id: image
            source: "https://source.unsplash.com/random"
            anchors.fill: parent
        }
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
        Rectangle {
            width: 300
            height: 150
            color: imgPalette.closestToWhite
            anchors {
                bottom: parent.bottom
                right: parent.right
            }
            Row {
                anchors.centerIn: parent
                Rectangle {
                    width: 10
                    height: 10
                    color: imgPalette.mostSaturated
                }
                Controls.Label {
                    text: "Lorem Ipsum dolor sit amet"
                    color: imgPalette.closestToBlack
                }
            }
        }
    }
}
