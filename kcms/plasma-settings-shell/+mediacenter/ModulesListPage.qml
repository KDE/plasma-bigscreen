/*

    SPDX-FileCopyrightText: 2011-2014 Sebastian Kügler <sebas@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.settings

Kirigami.Page {
    id: settingsRoot

    property alias currentIndex: listView.currentIndex

    Kirigami.Theme.colorSet: Kirigami.Theme.View
    background: Rectangle {
        color: Kirigami.Theme.backgroundColor
    }

    Component {
        id: settingsModuleDelegate
        Controls.ItemDelegate {
            id: delegateItem

            height: listView.height
            width: settingsRoot.width > Kirigami.Units.gridUnit * 20 ? settingsRoot.width/4 : settingsRoot.width
            enabled: true
            checked: listView.currentIndex == index
            leftPadding: Kirigami.Units.largeSpacing
            background: null
            Keys.onReturnPressed: clicked()
            contentItem: Item {
                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: Kirigami.Units.largeSpacing
                    Kirigami.Icon {
                        id: iconItem
                        Layout.alignment: Qt.AlignCenter
                        selected: delegateItem.down
                        Layout.maximumWidth: Layout.preferredWidth
                        Layout.preferredWidth: listView.currentIndex == index ? PlasmaCore.Units.iconSizes.enormous : PlasmaCore.Units.iconSizes.huge
                        Layout.preferredHeight: Layout.preferredWidth
                        Behavior on Layout.preferredWidth {
                            NumberAnimation {
                                duration: Kirigami.Units.longDuration
                                easing.type: Easing.InOutQuad
                            }
                        }
                        source: iconName
                    }

                    Controls.Label {
                        Layout.fillWidth: true
                        text: name
                        horizontalAlignment: Text.AlignHCenter
                    }
                    Controls.Label {
                        text: description
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        font.pointSize: Kirigami.Theme.defaultFont.pointSize -1
                        opacity: 0.6
                        elide: Text.ElideRight
                    }
                }
            }

            onClicked: {
                print("Clicked index: " + index + " current: " + listView.currentIndex + " " + name + " curr: " + rootItem.currentModule);
                // Only the first main page has a kcm property
                var container = kcmContainer.createObject(pageStack, {"kcm": model.kcm, "internalPage": model.kcm.mainUi});
                pageStack.push(container);
            }
        }
    }

    // This is pretty much a placeholder of what will be the sandboxing mechanism: this element will be a wayland compositor that will contain off-process kcm pages
    Component {
        id: kcmContainer

        KCMContainer {}
    }

    contentItem: ListView {
        id: listView
        focus: true
        spacing: 0
        orientation: ListView.Horizontal
        activeFocusOnTab: true
        keyNavigationEnabled: true
        highlightFollowsCurrentItem: true
        highlightMoveDuration: Kirigami.Units.longDuration
        snapMode: ListView.SnapToItem
        model: ModulesProxyModel{}
        delegate: settingsModuleDelegate
    }
}
