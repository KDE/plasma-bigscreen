kde_enable_exceptions()

add_definitions(-DTRANSLATION_DOMAIN=\"biglauncherplugin\")

set(biglauncherplugin_SRCS biglauncherplugin.cpp biglauncher_dbus.cpp applicationlistmodel.cpp voiceapplistmodel.cpp)

add_library(biglauncherplugin SHARED ${biglauncherplugin_SRCS})

target_link_libraries(biglauncherplugin Qt5::Gui Qt5::Core Qt5::Qml Qt5::DBus Qt5::Network KF5::Plasma KF5::I18n KF5::Notifications KF5::Service KF5::KIOWidgets)

install(TARGETS biglauncherplugin DESTINATION ${QML_INSTALL_DIR}/org/kde/private/biglauncher)

install(FILES qmldir DESTINATION ${QML_INSTALL_DIR}/org/kde/private/biglauncher)
