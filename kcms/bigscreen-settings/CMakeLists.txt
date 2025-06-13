# SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
# SPDX-FileCopyrightText: 2019 Aditya Mehra <aix.m@outlook.com>
# SPDX-License-Identifier: GPL-2.0-or-later

set(bigscreensettings_SRCS
    bigscreensettings.cpp bigscreensettings.h
    globalthemelistmodel.cpp globalthemelistmodel.h
    timedated_interface.cpp timedated_interface.h
)

kcmutils_add_qml_kcm(kcm_mediacenter_bigscreen_settings SOURCES ${bigscreensettings_SRCS})

target_link_libraries(kcm_mediacenter_bigscreen_settings
    Qt::DBus
    Qt::Gui
    Qt::Quick
    Qt::Qml
    KF6::ConfigCore
    KF6::Svg
    Plasma::Plasma
    KF6::I18n
    KF6::KCMUtilsQuick
    KF6::ConfigWidgets # KColorScheme
    KF6::CoreAddons
    KF6::Package
)
