# SPDX-FileCopyrightText: 2025 Seshan Ravikumar <seshan@sineware.ca>
# SPDX-License-Identifier: LicenseRef-KDE-Accepted-GPL
add_executable(plasma-bigscreen-uvcviewer)

ecm_add_qml_module(plasma-bigscreen-uvcviewer
    URI
    org.kde.plasma.bigscreen.uvcviewer
)

target_sources(plasma-bigscreen-uvcviewer
    PRIVATE
    main.cpp
)

ecm_target_qml_sources(plasma-bigscreen-uvcviewer
    SOURCES
    Main.qml
    UvcViewer.qml
    CameraHomePage.qml
)

target_link_libraries(plasma-bigscreen-uvcviewer
    PRIVATE
    Qt6::Quick
    Qt6::Qml
    Qt6::Gui
    Qt6::QuickControls2
    Qt6::Widgets
    KF6::I18n
    KF6::CoreAddons
    KF6::IconThemes
)

install(TARGETS plasma-bigscreen-uvcviewer ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
