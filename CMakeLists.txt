# Set minimum CMake version (required for CMake 3.0 or later)
cmake_minimum_required(VERSION 3.0)
cmake_policy(SET CMP0048 NEW)
project(plasma-big-launcher VERSION "2.0.0")

set(QT_MIN_VERSION "5.9.0")
set(KF5_MIN_VERSION "5.0.0")
 
# Use Extra CMake Modules (ECM) for common functionality.
# See http://api.kde.org/ecm/manual/ecm.7.html
# and http://api.kde.org/ecm/manual/ecm-kde-modules.7.html 
find_package(ECM REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH} ${ECM_KDE_MODULE_DIR} ${CMAKE_MODULE_PATH})
set(VERSION 2.1.0)

include(KDEInstallDirs)
include(KDECMakeSettings)
include(KDECompilerSettings NO_POLICY_SCOPE)
include(ECMInstallIcons)

# Locate plasma_install_package macro.
find_package(KF5 ${KF5_MIN_VERSION} REQUIRED COMPONENTS
    Plasma
    I18n
    Kirigami2
    Declarative
    KCMUtils
    Notifications
    PlasmaQuick
    KIO
    Wayland
    WindowSystem
)

find_package(Qt5 ${QT_MIN_VERSION} CONFIG REQUIRED COMPONENTS
    Quick
    Core
    Qml
    DBus
    Network
)

add_subdirectory(containments)
add_subdirectory(kcms)

plasma_install_package(shell org.kde.plasma.mycroft.bigscreen shells)
plasma_install_package(lookandfeel org.kde.plasma.mycroft.bigscreen look-and-feel lookandfeel)

install(DIRECTORY components/ DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/mycroft/bigscreen)

install(FILES bin/mycroft-skill-launcher.py DESTINATION ${BIN_INSTALL_DIR})

