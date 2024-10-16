kde_enable_exceptions()

add_definitions(-DTRANSLATION_DOMAIN=\"biglauncherhomescreen\")

kcoreaddons_add_plugin(org.kde.bigscreen.homescreen INSTALL_NAMESPACE "plasma/applets")
target_sources(org.kde.bigscreen.homescreen PRIVATE
    biglauncherhomescreen.cpp
    biglauncher_dbus.cpp
    applicationlistmodel.cpp
    kcmslistmodel.cpp
    favslistmodel.cpp
    configuration.cpp
    shortcuts.cpp
    settings/modulesmodel.cpp
    settings/module.cpp
)

target_link_libraries(org.kde.bigscreen.homescreen
    Qt::Gui
    Qt::Core
    Qt::Qml
    Qt::DBus
    Qt::Network
    Qt::Quick
    Plasma::Plasma
    KF6::I18n
    KF6::Notifications
    KF6::Service 
    KF6::KIOWidgets
    KF6::KCMUtilsQuick
    KF6::GlobalAccel
    Plasma::Activities
    PW::KWorkspace
    Plasma::ActivitiesStats
)
