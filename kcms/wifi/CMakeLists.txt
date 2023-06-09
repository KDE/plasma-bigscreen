kcmutils_add_qml_kcm(kcm_mediacenter_wifi SOURCES wifi.cpp INSTALL_NAMESPACE "kcms")
target_link_libraries(kcm_mediacenter_wifi KF6::KCMUtilsQuick)

