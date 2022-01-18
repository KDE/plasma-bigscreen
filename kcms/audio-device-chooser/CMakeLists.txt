include(ECMFindQmlModule)

ecm_find_qmlmodule(org.kde.plasma.core 2.0)

# KI18N Translation Domain for this library.
add_definitions(-DTRANSLATION_DOMAIN=\"kcm_audiodevice\")

########### next target ###############

set(kcm_audiodevice_PART_SRCS audiodevice.cpp)

add_library(kcm_audiodevice MODULE ${kcm_audiodevice_PART_SRCS})

target_link_libraries(kcm_audiodevice
    KF5::I18n
    KF5::KCMUtils
    KF5::QuickAddons
)

kcoreaddons_desktop_to_json(kcm_audiodevice "kcm_audiodevice.desktop")

########### install files ###############

install(TARGETS kcm_audiodevice DESTINATION ${KDE_INSTALL_PLUGINDIR}/kcms)
install(FILES kcm_audiodevice.desktop  DESTINATION  ${KDE_INSTALL_KSERVICES5DIR})
kpackage_install_package(package kcm_audiodevice kcms)

