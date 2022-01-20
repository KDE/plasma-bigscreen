import QtQuick 2.14
import QtQuick.Layouts 1.14
import QtQuick.Controls 2.14
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.kirigami 2.12 as Kirigami

PlasmaComponents3.Button {
    id: btnMap
    implicitWidth: parent.width
    padding: Kirigami.Units.largeSpacing

    Connections {
        target: hdmiCecConfig
        onUpdateKeyValue: {
            if (targetname == btnMap.objectName){
                console.log(targetname, btnMap.objectName, value)
                keyValue.text = value
            }
        }
    }

    background: Rectangle {
        Kirigami.Theme.inherit: false
        Kirigami.Theme.colorSet: Kirigami.Theme.Button
        color: btnMap.activeFocus ? Kirigami.Theme.linkColor : Kirigami.Theme.backgroundColor
        border.width: 1
        border.color: Kirigami.Theme.inactiveTextColor
    }

    contentItem: RowLayout {
        id: keyLayout

        PlasmaComponents.Label {
            Layout.preferredWidth: parent.width / 2
            horizontalAlignment: Text.AlignHCenter
            text: i18n(model.buttonDisplay)
        }
        PlasmaComponents.Label {
            id: keyValue
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            text: kcm.getCecKeyConfig(model.buttonType)
        }
    }

    Keys.onReturnPressed: clicked()

    onClicked: {
        keySetupPopUp.keyType = [model.buttonDisplay, model.buttonType]
        keySetupPopUp.open()
    }
}
