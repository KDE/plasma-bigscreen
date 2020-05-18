
import QtQuick 2.12
import QtQuick.Layouts 1.4
import QtQuick.Controls 2.12 as Controls
import org.kde.kirigami 2.13 as Kirigami
import org.kde.mycroft.bigscreen 1.0 as BigScreen

Image {
    id: image
    width: 900
    height: 600
    source: "https://source.unsplash.com/random"

    GridView {
        id: view
        anchors.fill: parent

        cellWidth: 300
        cellHeight: cellWidth/2
        model: ["desktop", "firefox", "vlc", "blender", "applications-games", "blinken", "adjustlevels", "cuttlefish", "calligrakrita", "folder-games", "applications-network", "applications-utilities", "view-left-close", "accessories-dictionary", "calligraflow", "multimedia-player",  "calligraauthor"]

        delegate: Item {
            id: delegate
            width: view.cellWidth
            height: view.cellHeight
            Rectangle {
                anchors {
                    fill: parent
                    margins: 10
                }
                radius: 5
                color: palette.dominantContrast
                Kirigami.ImageColors {
                    id: palette
                    source: modelData
                }
                RowLayout {
                    anchors.fill: parent

                    Kirigami.Icon {
                        id: icon
                        Layout.preferredHeight: delegate.height * 0.8
                        Layout.preferredWidth: Layout.preferredHeight
                        Layout.leftMargin: y
                        source: modelData
                    }
                    Kirigami.Heading {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        text: "Lorem"
                        //color: 0.2126 * palette.suggestedContrast.r + 0.7152 * palette.suggestedContrast.g + 0.0722 * palette.suggestedContrast.b > 0.6 ? "black" : "white"
                        color: useColors
                            ? Kirigami.ColorUtils.brightness(palette.dominantContrast) === Kirigami.ColorUtils.Light ? imagePalette.closestToBlack : imagePalette.closestToWhite
                            : PlasmaCore.ColorScope.textColor
                    }
                }
            }
        }
    }
}

