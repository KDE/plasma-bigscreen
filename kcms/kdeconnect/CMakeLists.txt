# SPDX-FileCopyrightText: 2019 Aditya Mehra <aix.m@outlook.com>
# SPDX-License-Identifier: GPL-2.0-or-later

kcmutils_add_qml_kcm(kcm_mediacenter_kdeconnect SOURCES kdeconnect.cpp)
target_link_libraries(kcm_mediacenter_kdeconnect KF6::KCMUtilsQuick)

