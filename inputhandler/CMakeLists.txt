# SPDX-FileCopyrightText: 2026 Devin Lin <devin@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

add_executable(plasma-bigscreen-inputhandler)
if (Qt6_VERSION VERSION_GREATER_EQUAL "6.8.0")
    set(private_code_option  "PRIVATE_CODE")
endif()
qt6_generate_wayland_protocol_client_sources(plasma-bigscreen-inputhandler FILES ${PLASMA_WAYLAND_PROTOCOLS_DIR}/fake-input.xml ${private_code_option})

target_sources(plasma-bigscreen-inputhandler PRIVATE
    main.cpp
    controllermanager.cpp
    abstractsystem.cpp
    kwinfakeinputsystem.cpp
    xdgremotedesktopsystem.cpp
    sdlcontroller.cpp
    device.cpp
    devicewatcher.cpp
    inputhandlerdbus.cpp
)

target_link_libraries(plasma-bigscreen-inputhandler
    ${CMAKE_DL_LIBS}
    Qt::Core
    Qt::DBus
    Qt::Gui
    Qt::WaylandClient
    KF6::ConfigCore
    KF6::Notifications
    KF6::Solid
    KF6::I18n
    KF6::DBusAddons
    KF6::CoreAddons
    KF6::WindowSystem
    SDL3::SDL3
    Wayland::Client
)
target_compile_definitions(plasma-bigscreen-inputhandler PRIVATE -DPROJECT_VERSION="${PROJECT_VERSION}")

if (TARGET PkgConfig::Libcec)
    set(LIBCEC_SRCS libcec/ceccontroller.cpp libcec/ceccontroller.h)
    target_sources(plasma-bigscreen-inputhandler PUBLIC ${LIBCEC_SRCS})
    target_link_libraries(plasma-bigscreen-inputhandler PkgConfig::Libcec)
    add_definitions(-DHAS_LIBCEC)
endif()

install(TARGETS plasma-bigscreen-inputhandler DESTINATION ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})

configure_file(org.kde.plasma.bigscreen.inputhandler.desktop.cmake ${CMAKE_CURRENT_BINARY_DIR}/org.kde.plasma.bigscreen.inputhandler.desktop @ONLY)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/org.kde.plasma.bigscreen.inputhandler.desktop DESTINATION ${KDE_INSTALL_APPDIR})
