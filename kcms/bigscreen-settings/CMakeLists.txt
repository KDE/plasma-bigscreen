set(bigscreensettings_SRCS
    bigscreensettings.cpp
    themelistmodel.cpp
    timedated_interface.cpp
)

kcmutils_add_qml_kcm(kcm_mediacenter_bigscreen_settings SOURCES ${bigscreensettings_SRCS} INSTALL_NAMESPACE kcms)

target_link_libraries(kcm_mediacenter_bigscreen_settings
    Qt::DBus
    Qt::Gui
    Qt::Quick
    Qt::Qml
    KF6::ConfigCore
    KF6::Svg
    Plasma::Plasma
    KF6::I18n
    KF6::KCMUtilsQuick
    KF6::ConfigWidgets # KColorScheme
    KF6::CoreAddons
)
