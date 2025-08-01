# SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

set(webappskcm_SRCS
    webappskcm.cpp
    webappcreator.cpp
    webappmanager.cpp
    webappmanagermodel.cpp
)

kcmutils_add_qml_kcm(kcm_mediacenter_webapps SOURCES ${webappskcm_SRCS})

target_link_libraries(kcm_mediacenter_webapps
    Qt::DBus
    Qt::Gui
    Qt::Quick
    Qt::Qml
    QCoro6::Qml
    KF6::ConfigCore
    KF6::Svg
    KF6::I18n
    KF6::KCMUtilsQuick
    KF6::ConfigWidgets
    KF6::CoreAddons
    KF6::Package
    Plasma::Plasma
)
