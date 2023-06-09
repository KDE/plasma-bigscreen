kcmutils_add_qml_kcm(kcm_mediacenter_kdeconnect SOURCES kdeconnect.cpp INSTALL_NAMESPACE "kcms")
target_link_libraries(kcm_mediacenter_kdeconnect KF6::KCMUtilsQuick)

