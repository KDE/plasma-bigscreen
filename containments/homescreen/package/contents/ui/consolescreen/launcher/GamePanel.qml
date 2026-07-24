import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami

Item {
    id:root

    property var modelData:null

    implicitHeight: Kirigami.Units.gridUnit * 6
    Layout.fillWidth: true

    ColumnLayout {
        anchors.fill: parent
        spacing: Kirigami.Units.largeSpacing

        // 1. Game Title (Large, bold TV font)
        QQC2.Label {
            Layout.fillWidth: true
            text: root.modelData?.name ?? i18n("Select a Game")
            font.pixelSize: Kirigami.Theme.defaultFont.pixelSize * 3 
            font.weight: Font.Bold
            color: "white"
            elide: Text.ElideRight
        }

        // 2. Structured Key-Value Metadata Grid
        GridLayout {
            Layout.fillWidth: true
            visible: root.modelData !== null
            
            // 6 columns creates 3 side-by-side Key-Value pairs
            columns: 6 
            rowSpacing: Kirigami.Units.smallSpacing
            columnSpacing: Kirigami.Units.mediumSpacing

            // --- PAIR 1: PLATFORM ---
            QQC2.Label {
                text: i18n("Platform:")
                opacity: 0.6
                font.weight: Font.DemiBold
            }
            QQC2.Label {
                text: root.modelData?.source ?? i18n("System")
                font.weight: Font.Bold
                // Add a trailing margin to separate this pair from the next key
                Layout.rightMargin: Kirigami.Units.gridUnit * 1.5 
            }

            // --- PAIR 2: PLAYTIME ---
            QQC2.Label {
                text: i18n("Playtime:")
                opacity: 0.6
                font.weight: Font.DemiBold
            }
            QQC2.Label {
                text: {
                    const played = root.modelData?.played_time;
                    if (!played || played <= 0) return i18n("Never played");
                    return i18n("%1 hrs", Math.round(played / 60));
                }
                font.weight: Font.Bold
                Layout.rightMargin: Kirigami.Units.gridUnit * 1.5
            }

            // --- PAIR 3: LAST PLAYED ---
            QQC2.Label {
                text: i18n("Last Played:")
                opacity: 0.6
                font.weight: Font.DemiBold
            }
            QQC2.Label {
                text: root.modelData?.last_played ?? i18n("Never")
                font.weight: Font.Bold
            }
        }
    }
}