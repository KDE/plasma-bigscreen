set(displaysettings_SRCS
    displaysettings.cpp
    displaymodel.cpp
)

kcmutils_add_qml_kcm(kcm_mediacenter_display SOURCES ${displaysettings_SRCS})

target_link_libraries(kcm_mediacenter_display
    Qt::DBus
    Qt::Gui
    Qt::Quick
    Qt::Qml
    KF6::I18n
    KF6::KCMUtilsQuick
)