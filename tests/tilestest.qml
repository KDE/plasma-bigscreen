
import QtQuick 2.12
import QtQuick.Layouts 1.4
import QtQuick.Controls 2.12 as Controls
import org.kde.kirigami 2.10 as Kirigami
import org.kde.mycroft.bigscreen 1.0 as BigScreen

GridView {
    id: root
    width: 900
    height: 500

    cellWidth: 300
    cellHeight: cellWidth/2
    model: ["desktop", "firefox", "vlc", "blender", "applications-games", "blinken", "view-left-close", "adjustlevels", "cuttlefish", "folder-games", "applications-network", "applications-utilities", "multimedia-player", "accessories-dictionary", "calligraflow", "calligrakrita", "calligraauthor"]

    delegate: Item {
        id: delegate
        width: root.cellWidth
        height: root.cellHeight
        Rectangle {
            anchors {
                fill: parent
                margins: 10
            }
            color: palette.suggestedContrast
            BigScreen.ImagePalette {
                id: palette
                sourceItem: icon
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
                    color: 0.2126 * palette.palette[0].complementary.r + 0.7152 * palette.palette[0].complementary.g + 0.0722 * palette.palette[0].complementary.b > 0.6 ? "black" : "white"
                }
            }
        }
    }
}
