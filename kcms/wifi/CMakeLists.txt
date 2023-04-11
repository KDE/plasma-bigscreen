kcoreaddons_add_plugin(kcm_mediacenter_wifi SOURCES wifi.cpp INSTALL_NAMESPACE "kcms")
target_link_libraries(kcm_mediacenter_wifi KF6::KCMUtilsQuick)
kpackage_install_package(package kcm_mediacenter_wifi kcms)

