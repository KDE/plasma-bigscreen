add_executable(audio-device-chooser main.cpp qml.qrc)

install(TARGETS audio-device-chooser ${INSTALL_TARGETS_DEFAULT_ARGS})
install(PROGRAMS org.audio.device.chooser.desktop DESTINATION ${XDG_APPS_INSTALL_DIR})

target_link_libraries(audio-device-chooser
  PRIVATE Qt5::Core Qt5::Quick)
