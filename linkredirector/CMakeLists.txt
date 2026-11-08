# SPDX-FileCopyrightText: 2026 User8395 <therealuser8395@proton.me>
# SPDX-License-Identifier: GPL-2.0-only

add_executable(plasma-bigscreen-linkredirector)

ecm_add_qml_module(plasma-bigscreen-linkredirector
    URI
    org.kde.plasma.bigscreen.linkredirector
)

target_sources(plasma-bigscreen-linkredirector
    PRIVATE
    main.cpp
    linkredirector.h
    linkredirector.cpp
)

ecm_target_qml_sources(plasma-bigscreen-linkredirector
    SOURCES
    Main.qml
)

target_link_libraries(plasma-bigscreen-linkredirector
    PRIVATE
    Qt6::Quick
    Qt6::Qml
    Qt6::Gui
    Qt::DBus
    Qt6::Widgets
    KF6::I18n
    KF6::CoreAddons
    KF6::IconThemes
    KF6::Service
    KF6::KIOGui
)

install(TARGETS plasma-bigscreen-linkredirector ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
install(PROGRAMS org.kde.plasma.bigscreen.linkredirector.desktop DESTINATION ${KDE_INSTALL_APPDIR})
