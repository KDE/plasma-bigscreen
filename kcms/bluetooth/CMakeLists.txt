# SPDX-FileCopyrightText: 2025 User8395 <therealuser8395@proton.me>
# SPDX-License-Identifier: GPL-2.0-or-later

kcmutils_add_qml_kcm(kcm_mediacenter_bluetooth SOURCES
    bluetooth.cpp bluetooth.h
    devicesproxymodel.cpp devicesproxymodel.h
)

target_link_libraries(kcm_mediacenter_bluetooth
    KF6::KCMUtilsQuick
    KF6::BluezQt
)