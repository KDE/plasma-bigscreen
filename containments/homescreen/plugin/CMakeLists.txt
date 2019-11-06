kde_enable_exceptions()

add_definitions(-DTRANSLATION_DOMAIN=\"biglauncherhomescreen\")

set(biglauncherhomescreen_SRCS
    biglauncherhomescreen.cpp
    biglauncher_dbus.cpp
    applicationlistmodel.cpp
    voiceapplistmodel.cpp)

add_library(plasma_containment_biglauncherhomescreen MODULE ${biglauncherhomescreen_SRCS})

kcoreaddons_desktop_to_json(plasma_containment_biglauncherhomescreen ../package/metadata.desktop)

target_link_libraries(plasma_containment_biglauncherhomescreen Qt5::Gui Qt5::Core Qt5::Qml Qt5::DBus Qt5::Network KF5::Plasma KF5::I18n KF5::Notifications KF5::Service KF5::KIOWidgets)

install(TARGETS plasma_containment_biglauncherhomescreen DESTINATION ${KDE_INSTALL_PLUGINDIR}/plasma/applets)

