/*
    SPDX-FileCopyrightText: 2019-2020 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
*/

import QtQuick 2.14
import QtQuick.Controls 2.14 as Controls
import org.kde.kirigami 2.12 as Kirigami

import org.kde.plasma.settings 0.1

Kirigami.Page {
    id: container
    title: internalPage.title
    property QtObject kcm
    property Item internalPage
    topPadding: 0
    leftPadding: 0
    rightPadding: 0
    bottomPadding: 0
    flickable: internalPage.flickable
    actions.main: internalPage.actions.main
    actions.contextualActions: internalPage.contextualActions

    background: null

    onInternalPageChanged: {
        internalPage.parent = contentItem;
        internalPage.anchors.fill = contentItem;
    }
    onActiveFocusChanged: {
        if (activeFocus) {
            internalPage.forceActiveFocus();
        }
    }

    Component.onCompleted: {
        kcm.load()
    }

    data: [
        Connections {
            target: kcm
            onPagePushed: {
                pageStack.push(kcmContainer.createObject(pageStack, {"internalPage": page}));
            }
            onPageRemoved: pageStack.pop();
        },
        Connections {
            target: pageStack
            onPageRemoved: {
                if (kcm.needsSave) {
                    kcm.save()
                }
                if (page == container) {
                    page.destroy();
                }
            }
        }
    ]
}
