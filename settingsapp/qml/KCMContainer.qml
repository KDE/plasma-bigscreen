// SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
// SPDX-FileCopyrightText: 2019 Aditya Mehra <aix.m@outlook.com>
// SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls

import org.kde.kirigami as Kirigami
import org.kde.bigscreen as Bigscreen

Kirigami.Page {
    id: container

    required property QtObject kcm
    required property Item internalPage

    // Whether this container holds a subpage pushed by the KCM, rather than the KCM's main page
    property bool isSubPage: false

    signal newPageRequested(page: var)
    signal pagePopRequested()
    signal pageIndexChanged(index: int)

    title: internalPage ? internalPage.title : ''

    function goBack() {
        if (isSubPage) {
            kcm.pop();
        }
    }

    header: Item {
        id: headerAreaTop
        height: root.headerHeight
        width: parent.width

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: container.leftPadding
            anchors.rightMargin: container.rightPadding
            anchors.bottomMargin: container.leftPadding
            spacing: Kirigami.Units.largeSpacing

            Bigscreen.Button {
                id: backButton
                visible: container.isSubPage
                icon.name: 'go-previous'
                icon.width: Kirigami.Units.iconSizes.smallMedium
                icon.height: Kirigami.Units.iconSizes.smallMedium
                flat: true

                Layout.alignment: Qt.AlignBottom

                onClicked: container.goBack()

                // Only wire up navigation when visible, since KeyNavigation
                // also creates implicit reverse mappings on the targets
                KeyNavigation.down: container.isSubPage ? container.internalPage : null
                KeyNavigation.left: container.isSubPage ? container.KeyNavigation.left : null
            }

            Kirigami.Heading {
                id: settingsTitle
                text: container.title

                Layout.fillWidth: true
                Layout.fillHeight: true

                verticalAlignment: Text.AlignBottom
                horizontalAlignment: Text.AlignLeft

                font.weight: Font.Light

                color: Kirigami.Theme.textColor
                fontSizeMode: Text.Fit
                minimumPixelSize: 16
                font.pixelSize: 32
            }
        }
    }

    topPadding: 0
    leftPadding: Kirigami.Units.gridUnit + Kirigami.Units.largeSpacing
    rightPadding: leftPadding
    bottomPadding: 0

    flickable: internalPage ? internalPage.flickable : null
    actions: (internalPage && internalPage.actions) ? internalPage.actions : []

    onInternalPageChanged: {
        if (internalPage) {
            internalPage.parent = contentItem;
            internalPage.anchors.fill = contentItem;

            // Ensure pages have keynavigation set
            internalPage.KeyNavigation.left = Qt.binding(() => container.KeyNavigation.left);
        }
    }
    onActiveFocusChanged: {
        if (activeFocus && internalPage) {
            internalPage.forceActiveFocus();
        }
    }

    Component.onCompleted: {
        // setting a binding seems to not work, add them manually
        if (internalPage && internalPage.actions) {
            for (let action of internalPage.actions) {
                actions.push(action);
            }
        }

        if (isSubPage) {
            // Allow reaching the back button with key navigation
            if (internalPage) {
                internalPage.KeyNavigation.up = backButton;
            }
        } else if (kcm.load !== undefined) {
            // Only load settings for the KCM's main page, otherwise opening
            // a subpage would discard unsaved changes
            kcm.load();
        }
    }

    data: [
        Connections {
            target: internalPage
            function onActionsChanged() {
                // We don't use page actions right now
                container.actions.clear();
                for (let action of internalPage.actions) {
                    container.actions.push(action);
                }
            }
        },
        Connections {
            target: kcm

            // Only the KCM's main page manages the page stack, so that these
            // signals aren't handled once per open page
            enabled: !container.isSubPage

            function onPagePushed(page) {
                container.newPageRequested(page);
            }
            function onPageRemoved() {
                container.pagePopRequested();
            }
            function onCurrentIndexChanged(index) {
                container.pageIndexChanged(index);
            }
            function onNeedsSaveChanged() {
                if (kcm.needsSave) {
                    kcm.save();
                }
            }
        }
    ]
}
