include(ECMFindQmlModule)

ecm_find_qmlmodule(org.kde.plasma.core 2.0)

kcoreaddons_add_plugin(kcm_mediacenter_kdeconnect SOURCES kdeconnect.cpp INSTALL_NAMESPACE "kcms")
target_link_libraries(kcm_mediacenter_kdeconnect KF6::KCMUtilsQuick)
kpackage_install_package(package kcm_mediacenter_kdeconnect kcms)

