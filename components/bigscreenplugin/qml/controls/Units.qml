// SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL

pragma Singleton

import QtQml
import org.kde.kirigami as Kirigami

QtObject {
    readonly property int horizontalPadding: Kirigami.Units.gridUnit
    readonly property int verticalPadding: Kirigami.Units.gridUnit

    readonly property int verticalSpacing: Kirigami.Units.gridUnit
    readonly property int horizontalSpacing: Kirigami.Units.largeSpacing

    readonly property int defaultFontPixelSize: 18
    readonly property int headingFontPixelSize: 22
}
