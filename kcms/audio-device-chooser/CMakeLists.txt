# KI18N Translation Domain for this library.
add_definitions(-DTRANSLATION_DOMAIN=\"kcm_mediacenter_audiodevice\")

########### next target ###############
set(kcm_mediacenter_audiodevice_PART_SRCS audiodevice.cpp)

kcmutils_add_qml_kcm(kcm_mediacenter_audiodevice SOURCES ${kcm_mediacenter_audiodevice_PART_SRCS})

target_link_libraries(kcm_mediacenter_audiodevice PRIVATE
    KF6::I18n
    KF6::KCMUtilsQuick
)
