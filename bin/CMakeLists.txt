# SPDX-FileCopyrightText: 2020 Bart Ribbers <bribbers@disroot.org>
# SPDX-FileCopyrightText: 2025 Seshan Ravikumar <seshan@sineware.ca>

# SPDX-License-Identifier: GPL-2.0-or-later

configure_file(plasma-bigscreen-wayland.in ${CMAKE_CURRENT_BINARY_DIR}/plasma-bigscreen-wayland)
install(PROGRAMS
	${CMAKE_CURRENT_BINARY_DIR}/plasma-bigscreen-wayland
	plasma-bigscreen-common-env
	plasma-bigscreen-swap-session
	DESTINATION ${KDE_INSTALL_BINDIR})

configure_file(plasma-bigscreen-wayland.desktop.cmake ${CMAKE_CURRENT_BINARY_DIR}/plasma-bigscreen-wayland.desktop)
configure_file(plasma-bigscreen-swap-session.desktop.cmake ${CMAKE_CURRENT_BINARY_DIR}/plasma-bigscreen-swap-session.desktop)

install(FILES
	${CMAKE_CURRENT_BINARY_DIR}/plasma-bigscreen-wayland.desktop
    DESTINATION ${KDE_INSTALL_DATADIR}/wayland-sessions
)

install(FILES
	${CMAKE_CURRENT_BINARY_DIR}/plasma-bigscreen-swap-session.desktop
	DESTINATION ${KDE_INSTALL_APPDIR}
)
