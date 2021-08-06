set(bigscreensettings_SRCS
    bigscreensettings.cpp
    themelistmodel.cpp
)

qt_add_dbus_interface(bigscreensettings_SRCS ${CMAKE_CURRENT_SOURCE_DIR}/timedated1.xml timedated_interface)

add_library(kcm_mediacenter_bigscreen_settings MODULE ${bigscreensettings_SRCS})

target_link_libraries(kcm_mediacenter_bigscreen_settings
    Qt5::DBus
    Qt5::Gui
    Qt5::Quick
    Qt5::Qml
    KF5::ConfigCore
    KF5::Plasma
    KF5::I18n
    KF5::KCMUtils
    KF5::QuickAddons
    KF5::CoreAddons
    )
kcoreaddons_desktop_to_json(kcm_mediacenter_bigscreen_settings "bigscreensettings.desktop")

install(FILES bigscreensettings.desktop DESTINATION ${KDE_INSTALL_KSERVICES5DIR})
install(TARGETS kcm_mediacenter_bigscreen_settings DESTINATION ${KDE_INSTALL_PLUGINDIR}/kcms)
kpackage_install_package(package kcm_mediacenter_bigscreen_settings kcms)
