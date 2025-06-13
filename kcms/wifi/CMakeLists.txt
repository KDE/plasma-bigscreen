# SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
# SPDX-FileCopyrightText: 2024 Aditya Mehra <aix.m@outlook.com>
# SPDX-License-Identifier: GPL-2.0-or-later

kcmutils_add_qml_kcm(kcm_mediacenter_wifi SOURCES wifi.cpp)
target_link_libraries(kcm_mediacenter_wifi KF6::KCMUtilsQuick)

