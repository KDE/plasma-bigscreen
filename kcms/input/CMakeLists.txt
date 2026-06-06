# SPDX-FileCopyrightText: 2026 Devin Lin <devin@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

qt_generate_dbus_interface(
    ${CMAKE_SOURCE_DIR}/inputhandler/inputhandlerdbus.h
    org.kde.plasma.bigscreen.inputhandler.xml
    OPTIONS -s -m -P
)
qt_add_dbus_interface(inputsettings_dbus_SRCS
    ${CMAKE_CURRENT_BINARY_DIR}/org.kde.plasma.bigscreen.inputhandler.xml
    inputhandlerinterface
)

kcmutils_add_qml_kcm(kcm_mediacenter_input SOURCES
    inputsettings.cpp inputsettings.h
    ${inputsettings_dbus_SRCS}
)

target_link_libraries(kcm_mediacenter_input
    Qt::DBus
    KF6::KCMUtilsQuick
    KF6::I18n
)
