include(ECMFindQmlModule)

ecm_find_qmlmodule(org.kde.plasma.core 2.0)

# KI18N Translation Domain for this library.
add_definitions(-DTRANSLATION_DOMAIN=\"kcm_mediacenter_audiodevice\")

########### next target ###############

set(kcm_mediacenter_audiodevice_PART_SRCS audiodevice.cpp)

add_library(kcm_mediacenter_audiodevice MODULE ${kcm_mediacenter_audiodevice_PART_SRCS})

target_link_libraries(kcm_mediacenter_audiodevice
    KF5::I18n
    KF5::KCMUtils
    KF5::QuickAddons
)

kcoreaddons_desktop_to_json(kcm_mediacenter_audiodevice "kcm_mediacenter_audiodevice.desktop")

########### install files ###############

install(TARGETS kcm_mediacenter_audiodevice DESTINATION ${KDE_INSTALL_PLUGINDIR}/kcms)
install(FILES kcm_mediacenter_audiodevice.desktop  DESTINATION  ${KDE_INSTALL_KSERVICES5DIR})
kpackage_install_package(package kcm_mediacenter_audiodevice kcms)

