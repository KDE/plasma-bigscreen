/*
    SPDX-FileCopyrightText: 2019 Aditya Mehra <aix.m@outlook.com>
    SPDX-FileCopyrightText: 2025 Seshan Ravikumar <seshan@sineware.ca>
    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Window
import QtQuick.Controls as Controls

import org.kde.kirigami as Kirigami
import org.kde.bigscreen as Bigscreen
import org.kde.private.biglauncher
import org.kde.layershell as LayerShell
import org.kde.plasma.plasmoid

Window {
    id: root
    title: i18n("Edit Home Screen")

    LayerShell.Window.scope: "overlay"
    LayerShell.Window.anchors: LayerShell.Window.AnchorTop | LayerShell.Window.AnchorLeft | LayerShell.Window.AnchorRight | LayerShell.Window.AnchorBottom
    LayerShell.Window.layer: LayerShell.Window.LayerTop
    LayerShell.Window.exclusionZone: -1

    flags: Qt.FramelessWindowHint
    color: 'transparent'

    property int currentPageIndex: 0

    function showOverlay() {
        favsContainerAddSection.positionViewAtBeginning();
        favsContainerRemoveSection.positionViewAtBeginning();
        root.showFullScreen();
    }

    function hideOverlay() {
        root.close();
    }

    onActiveChanged: {
        if (!active) {
            hideOverlay();
        }
    }

    onVisibleChanged: {
        if (visible) {
            opacityAnim.to = 1;
            opacityAnim.restart();

            pagePickerList.currentIndex = root.currentPageIndex;
            pagePickerList.forceActiveFocus();
        }
    }

    onClosing: (close) => {
        if (windowContents.opacity !== 0) {
            close.accepted = false;
            opacityAnim.to = 0;
            opacityAnim.restart();
        }
    }

    Rectangle {
        id: windowContents
        anchors.fill: parent

        color: Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 0.8)

        opacity: 0
        NumberAnimation on opacity {
            id: opacityAnim
            duration: 400
            easing.type: Easing.OutCubic
            onFinished: {
                if (windowContents.opacity === 0) {
                    root.close();
                }
            }
        }

        Bigscreen.BackHandler.onActivated: root.hideOverlay()

        Kirigami.Theme.inherit: false
        Kirigami.Theme.colorSet: Kirigami.Theme.View

        Rectangle {
            id: backgroundPanel
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: column.height - titleHeading.height - Kirigami.Units.gridUnit * 2
            color: Kirigami.Theme.backgroundColor
        }

        ColumnLayout {
            id: column
            anchors.fill: parent

            Kirigami.Heading {
                id: titleHeading
                Layout.fillWidth: true
                Layout.margins: Kirigami.Units.gridUnit
                text: root.title

                font.weight: Font.Light

                color: Kirigami.Theme.textColor
                fontSizeMode: Text.Fit
                minimumPixelSize: 16
                font.pixelSize: 32
            }

            RowLayout {
                Layout.fillHeight: true
                Layout.fillWidth: true
                spacing: 0

                // Left sidebar: page picker (settings-app style)
                Rectangle {
                    id: sidebar
                    Layout.fillHeight: true
                    Layout.preferredWidth: Math.max(Kirigami.Units.gridUnit * 20, root.width * 0.20)

                    color: Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 0.8)

                    ListView {
                        id: pagePickerList
                        anchors.fill: parent
                        leftMargin: Kirigami.Units.gridUnit + Kirigami.Units.largeSpacing
                        rightMargin: Kirigami.Units.gridUnit + Kirigami.Units.largeSpacing
                        topMargin: Kirigami.Units.largeSpacing
                        bottomMargin: Kirigami.Units.largeSpacing
                        spacing: Kirigami.Units.largeSpacing
                        keyNavigationEnabled: true

                        KeyNavigation.right: favsContainerAddSection

                        model: [i18n("Favorites")]

                        onCurrentItemChanged: {
                            if (currentItem) {
                                currentItem.forceActiveFocus();
                            }
                        }

                        delegate: Controls.Button {
                            id: pageDelegate
                            required property int index
                            required property string modelData

                            width: pagePickerList.width - pagePickerList.leftMargin - pagePickerList.rightMargin
                            text: modelData

                            leftPadding: Kirigami.Units.gridUnit * 2
                            rightPadding: Kirigami.Units.gridUnit * 2
                            topPadding: Kirigami.Units.largeSpacing
                            bottomPadding: Kirigami.Units.largeSpacing

                            readonly property bool selected: root.currentPageIndex === index

                            onClicked: root.currentPageIndex = index
                            Keys.onReturnPressed: root.currentPageIndex = index

                            background: Bigscreen.DelegateBackground {
                                control: pageDelegate
                                raisedBackground: false
                                translucentHighlight: true
                                highlighted: pageDelegate.selected
                                borderHighlighted: highlighted || (pageDelegate.ListView.isCurrentItem && pagePickerList.activeFocus)
                            }

                            contentItem: Kirigami.Heading {
                                text: pageDelegate.text
                                font.weight: Font.Medium
                                elide: Text.ElideRight
                            }
                        }
                    }
                }

                StackLayout {
                    id: editStack
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    currentIndex: root.currentPageIndex

                    RowLayout {
                        Layout.fillHeight: true
                        Layout.fillWidth: true

                        ListView {
                            id: favsContainerAddSection

                            Layout.margins: Kirigami.Units.gridUnit
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            KeyNavigation.right: favsContainerRemoveSection
                            KeyNavigation.left: pagePickerList

                            model: Plasmoid.applicationListModel
                            clip: true
                            keyNavigationEnabled: true
                            snapMode: ListView.SnapOneItem
                            spacing: Kirigami.Units.smallSpacing

                            Kirigami.Theme.inherit: false
                            Kirigami.Theme.colorSet: Kirigami.Theme.Window

                            header: Controls.Label {
                                text: i18n("Add Favorites")
                                font.pixelSize: Bigscreen.Units.headingFontPixelSize
                                elide: Text.ElideRight
                                bottomPadding: Kirigami.Units.largeSpacing
                            }

                            delegate: Bigscreen.ButtonDelegate {
                                width: favsContainerAddSection.width
                                text: model.ApplicationNameRole
                                icon.name: model.ApplicationIconRole
                                trailing: Kirigami.Icon {
                                    source: "list-add-symbolic"
                                    implicitWidth: Kirigami.Units.iconSizes.smallMedium
                                    implicitHeight: Kirigami.Units.iconSizes.smallMedium
                                }
                                onClicked: {
                                    FavsManager.addFav(Plasmoid.applicationListModel.itemMap(index));
                                }
                            }
                        }

                        ListView {
                            id: favsContainerRemoveSection

                            Layout.margins: Kirigami.Units.gridUnit
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            KeyNavigation.left: favsContainerAddSection

                            model: Plasmoid.favsListModel
                            clip: true
                            keyNavigationEnabled: true
                            snapMode: ListView.SnapOneItem
                            spacing: Kirigami.Units.smallSpacing

                            Kirigami.Theme.inherit: false
                            Kirigami.Theme.colorSet: Kirigami.Theme.Window

                            header: Controls.Label {
                                text: i18n("Remove Favorites")
                                font.pixelSize: Bigscreen.Units.headingFontPixelSize
                                elide: Text.ElideRight
                                bottomPadding: Kirigami.Units.largeSpacing
                            }

                            delegate: Bigscreen.ButtonDelegate {
                                width: favsContainerRemoveSection.width
                                text: model.ApplicationNameRole
                                icon.name: model.ApplicationIconRole
                                trailing: Kirigami.Icon {
                                    source: "list-remove-symbolic"
                                    implicitWidth: Kirigami.Units.iconSizes.smallMedium
                                    implicitHeight: Kirigami.Units.iconSizes.smallMedium
                                }
                                onClicked: {
                                    FavsManager.removeFav(Plasmoid.favsListModel.itemMap(index));
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
