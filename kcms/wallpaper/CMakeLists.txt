# SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
# SPDX-FileCopyrightText: 2024 Aditya Mehra <aix.m@outlook.com>
# SPDX-License-Identifier: GPL-2.0-or-later

kcmutils_add_qml_kcm(kcm_mediacenter_wallpaper SOURCES wallpaper.cpp)
target_link_libraries(kcm_mediacenter_wallpaper
    KF6::KCMUtilsQuick
    Qt6::DBus
)
