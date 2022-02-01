configure_file(plasma-bigscreen-wayland.in ${CMAKE_CURRENT_BINARY_DIR}/plasma-bigscreen-wayland)
install(PROGRAMS
	${CMAKE_CURRENT_BINARY_DIR}/plasma-bigscreen-wayland
	plasma-bigscreen-x11
	DESTINATION ${BIN_INSTALL_DIR})

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
