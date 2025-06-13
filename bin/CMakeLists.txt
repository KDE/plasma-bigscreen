# SPDX-FileCopyrightText: 2020 Bart Ribbers <bribbers@disroot.org>
# SPDX-License-Identifier: GPL-2.0-or-later

configure_file(plasma-bigscreen-wayland.in ${CMAKE_CURRENT_BINARY_DIR}/plasma-bigscreen-wayland)
install(PROGRAMS
	${CMAKE_CURRENT_BINARY_DIR}/plasma-bigscreen-wayland
	plasma-bigscreen-x11
	DESTINATION ${KDE_INSTALL_BINDIR})

configure_file(plasma-bigscreen-wayland.desktop.cmake ${CMAKE_CURRENT_BINARY_DIR}/plasma-bigscreen-wayland.desktop)
configure_file(plasma-bigscreen-x11.desktop.cmake ${CMAKE_CURRENT_BINARY_DIR}/plasma-bigscreen-x11.desktop)

install(FILES
	${CMAKE_CURRENT_BINARY_DIR}/plasma-bigscreen-wayland.desktop
    DESTINATION ${KDE_INSTALL_DATADIR}/wayland-sessions
)

install(FILES
	${CMAKE_CURRENT_BINARY_DIR}/plasma-bigscreen-x11.desktop
    DESTINATION ${KDE_INSTALL_DATADIR}/xsessions
)
