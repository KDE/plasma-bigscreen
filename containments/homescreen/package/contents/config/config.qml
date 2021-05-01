/* SPDX-FileCopyrightText: 2019 Aditya Mehra <aix.m@outlook.com>

    SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL
*/

import QtQuick 2.14
import org.kde.plasma.configuration 2.0

ConfigModel {
    ConfigCategory {
            name: i18n('General')
            icon: 'preferences-system-windows'
            source: 'config/configGeneral.qml'
    }
}
