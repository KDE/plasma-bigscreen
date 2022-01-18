# Set minimum CMake version (required for CMake 3.0 or later)
cmake_minimum_required(VERSION 3.16)
cmake_policy(SET CMP0048 NEW)
project(plasma-big-launcher VERSION "2.0.0")

set(QT_MIN_VERSION "5.14.0")
set(KF5_MIN_VERSION "5.70.0")
 
# Use Extra CMake Modules (ECM) for common functionality.
# See http://api.kde.org/ecm/manual/ecm.7.html
# and http://api.kde.org/ecm/manual/ecm-kde-modules.7.html 
find_package(ECM REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH} ${ECM_KDE_MODULE_DIR} ${CMAKE_MODULE_PATH})
set(VERSION 2.1.0)

include(ECMFindQmlModule)
include(KDEInstallDirs)
include(KDECMakeSettings)
include(KDECompilerSettings NO_POLICY_SCOPE)
include(ECMInstallIcons)

# Locate plasma_install_package macro.
find_package(KF5 ${KF5_MIN_VERSION} REQUIRED COMPONENTS
    Activities
    ActivitiesStats
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

find_package(LibKWorkspace 5.19 CONFIG REQUIRED)


find_package(Qt5 ${QT_MIN_VERSION} CONFIG REQUIRED COMPONENTS
    Quick
    Core
    Qml
    DBus
    Network
    Multimedia
)

ecm_find_qmlmodule(Mycroft 1.0)

if(NOT ${Mycroft-QMLModule_FOUND})
    message(WARNING "Could not find the Mycroft QML module. Voice interaction features will not be available.")
endif()

add_subdirectory(bin)
add_subdirectory(containments)
add_subdirectory(kcms)
add_subdirectory(components)
add_subdirectory(sounds)

plasma_install_package(shell org.kde.plasma.mycroft.bigscreen shells)
plasma_install_package(lookandfeel org.kde.plasma.mycroft.bigscreen look-and-feel lookandfeel)


install(FILES bin/mycroft-skill-launcher.py DESTINATION ${BIN_INSTALL_DIR})

if(ECM_VERSION VERSION_GREATER_EQUAL 5.79)
    include(KDEClangFormat)
    include(KDEGitCommitHooks)
    file(GLOB_RECURSE ALL_CLANG_FORMAT_SOURCE_FILES *.cpp *.h)
    kde_clang_format(${ALL_CLANG_FORMAT_SOURCE_FILES})
    kde_configure_git_pre_commit_hook(CHECKS CLANG_FORMAT)
endif()

feature_summary(WHAT ALL INCLUDE_QUIET_PACKAGES FATAL_ON_MISSING_REQUIRED_PACKAGES)
