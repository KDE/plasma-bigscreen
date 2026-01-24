# SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
# SPDX-License-Identifier: LicenseRef-KDE-Accepted-GPL

add_executable(plasma-bigscreen-settings)

ecm_add_qml_module(plasma-bigscreen-settings
    URI
    org.kde.plasma.bigscreen.settings
)

target_sources(plasma-bigscreen-settings
    PRIVATE
    main.cpp
    kcmslistmodel.cpp
    module.cpp
    settingsapp.cpp
)

ecm_target_qml_sources(plasma-bigscreen-settings
    SOURCES
    qml/Main.qml
    qml/ConfigWindowSidebar.qml
    qml/KCMContainer.qml
)

target_link_libraries(plasma-bigscreen-settings
    PRIVATE
    Qt6::Quick
    Qt6::Qml
    Qt6::Gui
    Qt6::Widgets
    KF6::I18n
    KF6::CoreAddons
    KF6::KCMUtils
    KF6::IconThemes
    KF6::I18nQml
    KF6::WindowSystem
    KF6::DBusAddons
)

install(TARGETS plasma-bigscreen-settings ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
