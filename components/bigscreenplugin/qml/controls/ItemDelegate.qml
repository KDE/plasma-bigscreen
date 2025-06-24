// SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later


import QtQuick
import QtQuick.Templates as T
import QtQuick.Layouts
import QtQuick.Controls as QQC2

import org.kde.kirigami as Kirigami
import org.kde.bigscreen as Bigscreen

T.ItemDelegate {
    id: root

    /*!
       \brief Whether the delegate should be visually raised over the view.

       \default true
     */
    property bool raisedBackground: true

    verticalPadding: Units.verticalPadding
    horizontalPadding: Units.horizontalPadding
    leftPadding: verticalPadding
    rightPadding: verticalPadding
    topPadding: horizontalPadding
    bottomPadding: horizontalPadding

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding,
                             implicitIndicatorHeight + topPadding + bottomPadding)

    spacing: Kirigami.Units.smallSpacing

    topInset: TableView.view ? 0 : Math.ceil(Kirigami.Units.mediumSpacing / 2)
    bottomInset: TableView.view ? 0 : Math.ceil(Kirigami.Units.mediumSpacing / 2)
    leftInset: TableView.view ? 0 : Kirigami.Units.smallSpacing
    rightInset: TableView.view ? 0 : Kirigami.Units.smallSpacing

    focusPolicy: Qt.StrongFocus
    hoverEnabled: true
    background: DelegateBackground {
        control: root
        raisedBackground: root.raisedBackground
        neutralBackgroundColor: Kirigami.Theme.alternateBackgroundColor
    }

    icon {
        width: Kirigami.Units.iconSizes.medium
        height: Kirigami.Units.iconSizes.medium
    }

    Layout.fillWidth: true

    onActiveFocusChanged: {
        if (activeFocus) {
            Bigscreen.NavigationSoundEffects.playMovingSound();
        }
    }
}
