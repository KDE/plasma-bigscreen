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

    signal newPageRequested(page: var)

    title: internalPage.title

    header: Item {
        id: headerAreaTop
        height: root.headerHeight
        width: parent.width

        Kirigami.Heading {
            id: settingsTitle
            text: internalPage ? internalPage.title : ''
            anchors.fill: parent

            padding: container.leftPadding
            verticalAlignment: Text.AlignBottom
            horizontalAlignment: Text.AlignLeft

            font.weight: Font.Light

            color: Kirigami.Theme.textColor
            fontSizeMode: Text.Fit
            minimumPixelSize: 16
            font.pixelSize: 32
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
        if (kcm.load !== undefined) {
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
            function onPagePushed(page) {
                container.newPageRequested(page);
            }
            function onPageRemoved() {
                pageStack.pop();
                hideOverlay();
            }
            function onNeedsSaveChanged() {
                if (kcm.needsSave) {
                    kcm.save();
                }
            }
        },
        Connections {
            target: kcm
            function onCurrentIndexChanged(index) {
                const index_with_offset = index + 1;
                if (index_with_offset !== pageStack.currentIndex) {
                    pageStack.currentIndex = index_with_offset;
                }
            }
        }
    ]
}
