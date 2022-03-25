kde_enable_exceptions()

add_definitions(-DTRANSLATION_DOMAIN=\"biglauncherhomescreen\")

set(biglauncherhomescreen_SRCS
    biglauncherhomescreen.cpp
    biglauncher_dbus.cpp
    applicationlistmodel.cpp
    kcmslistmodel.cpp
    configuration.cpp
    )

add_library(plasma_containment_biglauncherhomescreen MODULE ${biglauncherhomescreen_SRCS})

kcoreaddons_desktop_to_json(plasma_containment_biglauncherhomescreen ../package/metadata.desktop)

target_link_libraries(plasma_containment_biglauncherhomescreen
                      Qt::Gui
                      Qt::Core
                      Qt::Qml
                      Qt::DBus
                      Qt::Network
                      KF5::Plasma
                      KF5::I18n
                      KF5::Notifications
                      KF5::Service KF5::KIOWidgets
                      KF5::Activities
                      PW::KWorkspace
                      KF5::ActivitiesStats)

install(TARGETS plasma_containment_biglauncherhomescreen DESTINATION ${KDE_INSTALL_PLUGINDIR}/plasma/applets)

