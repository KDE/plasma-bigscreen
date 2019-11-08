cmake_minimum_required(VERSION 3.5)

project(audio-device-chooser LANGUAGES CXX)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(ECM REQUIRED NO_MODULE)

set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH} ${ECM_KDE_MODULE_DIR} "${CMAKE_SOURCE_DIR}/cmake")

include(KDEInstallDirs)
include(KDECMakeSettings)
include(KDECompilerSettings)
include(ECMInstallIcons)
include(FeatureSummary)

find_package(PkgConfig REQUIRED)

find_package(Qt5 ${QT_MIN_VERSION} REQUIRED COMPONENTS
    Core
    Qml
    Quick
)

find_package(KF5 ${KF5_MIN_VERSION} REQUIRED
    I18n
    Kirigami2
)

add_executable(audio-device-chooser main.cpp qml.qrc)

install(TARGETS audio-device-chooser ${INSTALL_TARGETS_DEFAULT_ARGS})
install(PROGRAMS org.audio.device.chooser.desktop DESTINATION ${XDG_APPS_INSTALL_DIR})

target_compile_definitions(audio-device-chooser
  PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>)
target_link_libraries(audio-device-chooser
  PRIVATE Qt5::Core Qt5::Quick)
