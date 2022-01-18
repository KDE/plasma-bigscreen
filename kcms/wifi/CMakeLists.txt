include(ECMFindQmlModule)
ecm_find_qmlmodule(org.kde.plasma.core 2.0)

# KI18N Translation Domain for this library.
add_definitions(-DTRANSLATION_DOMAIN=\"kcm_mediacenter_wifi\")

########### next target ###############

set(kcm_mediacenter_wifi_PART_SRCS wifi.cpp)

add_library(kcm_mediacenter_wifi MODULE ${kcm_mediacenter_wifi_PART_SRCS})

target_link_libraries(kcm_mediacenter_wifi
    KF5::I18n
    KF5::KCMUtils
    KF5::QuickAddons
)

kcoreaddons_desktop_to_json(kcm_mediacenter_wifi "mediacenter_wifi.desktop")

########### install files ###############

install(TARGETS kcm_mediacenter_wifi DESTINATION ${KDE_INSTALL_PLUGINDIR}/kcms)
install(FILES mediacenter_wifi.desktop  DESTINATION  ${KDE_INSTALL_KSERVICES5DIR})
kpackage_install_package(package kcm_mediacenter_wifi kcms)

