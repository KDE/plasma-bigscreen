set(bigscreensettings_SRCS
    bigscreensettings.cpp
    themelistmodel.cpp
    timedated_interface.cpp
)

add_library(kcm_mediacenter_bigscreen_settings MODULE ${bigscreensettings_SRCS})

target_link_libraries(kcm_mediacenter_bigscreen_settings
    Qt::DBus
    Qt::Gui
    Qt::Quick
    Qt::Qml
    KF6::ConfigCore
    KF6::Plasma
    KF6::I18n
    KF6::KCMUtils
    KF6::QuickAddons
    KF6::CoreAddons
    )

install(TARGETS kcm_mediacenter_bigscreen_settings DESTINATION ${KDE_INSTALL_PLUGINDIR}/kcms)
kpackage_install_package(package kcm_mediacenter_bigscreen_settings kcms)
