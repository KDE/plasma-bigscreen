/*
    Copyright 2019 Aditya Mehra <aix.m@outlook.com>
    Copyright 2014-2015 Harald Sitter <sitter@kde.org>
    Copyright 2019 Sefa Eyeoglu <contact@scrumplex.net>
    
    This program is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public License as
    published by the Free Software Foundation; either version 2 of
    the License or (at your option) version 3 or any later version
    accepted by the membership of KDE e.V. (or its successor approved
    by the membership of KDE e.V.), which shall act as a proxy
    defined in Section 14 of version 3 of the license.
    
    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.
    
    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.kirigami 2.10 as Kirigami
import org.kde.plasma.private.volume 0.1

Kirigami.AbstractListItem {
    id: delegate
    width: parent.width
    height: parent.height
    property bool isPlayback: type.substring(0, 4) == "sink"
    property bool onlyOne: false
    readonly property var currentPort: Ports[ActivePortIndex]
    property string type
    signal setDefault
    highlighted: false

    onSetDefault: {
      PulseObject.default = true
    }

    ColumnLayout {
        anchors.fill: parent

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Label {
                id: inputText
                Layout.leftMargin: Kirigami.Units.largeSpacing
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                visible: !portbox.visible
                elide: Text.ElideRight
                text: !currentPort ? Description : i18ndc("kcm_pulseaudio", "label of device items", "%1 (%2)", currentPort.description, Description)
            }


            ComboBox {
                id: portbox
                Layout.fillWidth: true
                Layout.minimumWidth: Kirigami.Units.gridUnit * 10
                visible: portbox.count > 1
                enabled: portbox.count > 1
                Layout.alignment: Qt.AlignVCenter
                model: {
                    var items = [];
                    for (var i = 0; i < Ports.length; ++i) {
                        var port = Ports[i];
                        if (port.availability != Port.Unavailable) {
                            items.push(port.description);
                        }
                    }
                    return items
                }
                currentIndex: isPlayback ? 0 : ActivePortIndex
                onActivated: ActivePortIndex = index
                onModelChanged: console.log(model)
            }

            Item {
                //Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                Layout.preferredWidth: Kirigami.Units.gridUnit * 30
                Layout.preferredHeight: parent.height
                Kirigami.Icon {
                    id: defaultButton
                    source: "answer-correct"

                    anchors.centerIn: parent
                    width: Kirigami.Units.iconSizes.medium
                    height: Kirigami.Units.iconSizes.medium
                    visible: PulseObject.default ? 1 : 0
                }
            }
        }
    }

    onClicked: {
        PulseObject.default = true;
    }
}
