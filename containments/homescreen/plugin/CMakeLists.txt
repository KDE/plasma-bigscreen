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

target_link_libraries(plasma_containment_biglauncherhomescreen
                      Qt::Gui
                      Qt::Core
                      Qt::Qml
                      Qt::DBus
                      Qt::Network
                      KF6::Plasma
                      KF6::I18n
                      KF6::Notifications
                      KF6::Service KF6::KIOWidgets
                      KF6::Activities
                      PW::KWorkspace
                      KF6::ActivitiesStats)

install(TARGETS plasma_containment_biglauncherhomescreen DESTINATION ${KDE_INSTALL_PLUGINDIR}/plasma/applets)

