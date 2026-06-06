# SPDX-FileCopyrightText: 2026 Devin Lin <devin@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

add_executable(plasma-bigscreen-inputhandler)
if (Qt6_VERSION VERSION_GREATER_EQUAL "6.8.0")
    set(private_code_option  "PRIVATE_CODE")
endif()

qt_generate_dbus_interface(
    ${CMAKE_CURRENT_SOURCE_DIR}/inputhandlerdbus.h
    org.kde.plasma.bigscreen.inputhandler.xml
    OPTIONS -s -m -P
)
qt_add_dbus_adaptor(inputhandler_dbus_SRCS
    ${CMAKE_CURRENT_BINARY_DIR}/org.kde.plasma.bigscreen.inputhandler.xml
    inputhandlerdbus.h
    InputHandlerDBus
)

target_sources(plasma-bigscreen-inputhandler PRIVATE
    main.cpp
    controllermanager.cpp
    xdgremotedesktopsystem.cpp
    sdlcontroller.cpp
    device.cpp
    devicewatcher.cpp
    inputhandlerdbus.cpp
    ${inputhandler_dbus_SRCS}
)

kconfig_add_kcfg_files(plasma-bigscreen-inputhandler GENERATE_MOC inputhandlersettings.kcfgc)

target_link_libraries(plasma-bigscreen-inputhandler
    ${CMAKE_DL_LIBS}
    Qt::Core
    Qt::DBus
    Qt::Gui
    KF6::ConfigCore
    KF6::Notifications
    KF6::Solid
    KF6::I18n
    KF6::DBusAddons
    KF6::CoreAddons
    KF6::WindowSystem
    SDL3::SDL3
)
target_compile_definitions(plasma-bigscreen-inputhandler PRIVATE -DPROJECT_VERSION="${PROJECT_VERSION}")

if (TARGET PkgConfig::Libcec)
    set(LIBCEC_SRCS
        libcec/ceccontroller.cpp
        libcec/ceccontroller.h
        libcec/cecworker.cpp
        libcec/cecworker.h
    )
    target_sources(plasma-bigscreen-inputhandler PUBLIC ${LIBCEC_SRCS})
    target_link_libraries(plasma-bigscreen-inputhandler PkgConfig::Libcec)
    add_definitions(-DHAS_LIBCEC)
endif()

install(TARGETS plasma-bigscreen-inputhandler DESTINATION ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})

configure_file(org.kde.plasma.bigscreen.inputhandler.desktop.cmake ${CMAKE_CURRENT_BINARY_DIR}/org.kde.plasma.bigscreen.inputhandler.desktop @ONLY)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/org.kde.plasma.bigscreen.inputhandler.desktop DESTINATION ${KDE_INSTALL_APPDIR})
install(FILES 40-uinput.rules DESTINATION ${KDE_INSTALL_LIBDIR}/udev/rules.d)
