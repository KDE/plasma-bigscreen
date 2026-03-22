// SPDX-FileCopyrightText: 2026 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Window
import QtQuick.Controls as QQC2

import org.kde.kirigami as Kirigami
import org.kde.bigscreen as Bigscreen

/**
 * Scrollable page built on Kirigami.ScrollablePage that always
 * keeps the selected item on the page in view.
 */

Kirigami.ScrollablePage {
    id: root

    // HACK: There are cases where Window.window is null until a parent is set for the page.
    //       Window.window doesn't seem to automatically listen to value changes, so we need to reload
    //       the entire Connections to get a non-null window.
    property var __window: null

    onParentChanged: {
        if (parent) {
            if (Window.window && __window !== Window.window) {
                __window = Window.window
                Window.window.activeFocusItemChanged.connect(__onActiveFocusItemChanged);
            }
        }
    }

    Component.onCompleted: {
        if (Window.window && __window !== Window.window) {
            __window = Window.window;
            Window.window.activeFocusItemChanged.connect(__onActiveFocusItemChanged);
        }
    }

    function __onActiveFocusItemChanged() {
        // If the active focused item is a child of this page, scroll to where it is
        let item = Window.activeFocusItem;
        if (__isChildOfRoot(item)) {
            // ensureVisible requires offset since it assumes flickable's coordinate system
            const itemPosition = root.flickable.contentItem.mapFromItem(item, 0, 0);
            root.ensureVisible(item, itemPosition.x - item.x, itemPosition.y - item.y);
        }
    }

    // Whether the item is a child of root
    function __isChildOfRoot(item) {
        var cur = item;
        while (cur !== null) {
            if (cur === root.flickable) {
                return true;
            }
            cur = cur.parent;
        }
        return false;
    }
}
