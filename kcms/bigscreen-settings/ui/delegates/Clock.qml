import QtQuick 2.15
import QtQuick.Controls 2.15
import org.kde.kirigami as Kirigami

Rectangle {
    id: clockFace
    width: Math.min(parent.width, parent.height)
    height: width
    property var bgColor
    property var textColor
    property var highlightColor
    color: highlightColor

    // Rim
    Rectangle {
        id: rim
        width: parent.width * 0.98
        height: parent.height * 0.98
        color: bgColor
        anchors.centerIn: parent
        radius: 8
    }

    // Markings
    Text {
        text: i18n("12:00")
        font.bold: true
        color: textColor
        anchors.top: rim.top
        anchors.topMargin: Kirigami.Units.smallSpacing / 2
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Text {
        id: bottomTextTimeRep
        text: i18n("6:00")
        font.bold: true
        color: textColor
        anchors.bottom: rim.bottom
        anchors.bottomMargin: Kirigami.Units.smallSpacing / 2
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Text {
        text: i18n("9:00")
        font.bold: true
        color: textColor
        anchors.left: rim.left
        anchors.leftMargin: Kirigami.Units.smallSpacing / 2
        anchors.verticalCenter: parent.verticalCenter
    }

    Text {
        text: i18n("3:00")
        font.bold: true
        color: textColor
        anchors.right: rim.right
        anchors.rightMargin: Kirigami.Units.smallSpacing / 2
        anchors.verticalCenter: parent.verticalCenter
    }

    // Digital clock text
    Rectangle {        
        anchors.centerIn: parent
        color: bgColor
        width: digitalClockText.implicitWidth + Kirigami.Units.largeSpacing
        height: digitalClockText.implicitHeight + Kirigami.Units.smallSpacing

        Text {
            id: digitalClockText
            text: i18n("09:05 AM")
            font.pixelSize: Math.min(clockFace.width, clockFace.height) * 0.15
            font.bold: true
            color: highlightColor
            anchors.centerIn: parent
        }
    }
}
