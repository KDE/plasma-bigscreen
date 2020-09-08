configure_file(plasma-bigscreen-wayland.in ${CMAKE_CURRENT_BINARY_DIR}/plasma-bigscreen-wayland)
install(PROGRAMS ${CMAKE_CURRENT_BINARY_DIR}/plasma-bigscreen-wayland DESTINATION ${BIN_INSTALL_DIR})

configure_file(plasma-bigscreen-wayland.desktop.cmake ${CMAKE_CURRENT_BINARY_DIR}/plasma-bigscreen-wayland.desktop)
install(FILES
        ${CMAKE_CURRENT_BINARY_DIR}/plasma-bigscreen-wayland.desktop
        DESTINATION ${KDE_INSTALL_DATADIR}/wayland-sessions
)
