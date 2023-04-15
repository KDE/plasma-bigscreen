# Set minimum CMake version (required for CMake 3.0 or later)
cmake_minimum_required(VERSION 3.16)

project(plasma-bigscreen)
set(PROJECT_VERSION "5.27.80")
set(PROJECT_VERSION_MAJOR 6)

set(QT_MIN_VERSION "6.4.0")
set(KF5_MIN_VERSION "5.240.0")
 
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Use Extra CMake Modules (ECM) for common functionality.
# See http://api.kde.org/ecm/manual/ecm.7.html
# and http://api.kde.org/ecm/manual/ecm-kde-modules.7.html 
find_package(ECM 5.240 REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH} ${CMAKE_MODULE_PATH})

include(ECMFindQmlModule)
include(KDEInstallDirs)
include(KDECMakeSettings)
include(KDECompilerSettings NO_POLICY_SCOPE)
include(ECMInstallIcons)
include(ECMDeprecationSettings)

remove_definitions(-DQT_NO_CAST_FROM_ASCII)

find_package(KF6 ${KF5_MIN_VERSION} REQUIRED COMPONENTS
    Activities
    ActivitiesStats
    Plasma
    I18n
    Kirigami2
    KCMUtils
    Notifications
    PlasmaQuick
    KIO
    Wayland
    WindowSystem
)

find_package(LibKWorkspace 5.19 CONFIG REQUIRED)

find_package(Qt${QT_MAJOR_VERSION} ${QT_MIN_VERSION} CONFIG REQUIRED COMPONENTS
    Quick
    Core
    Qml
    DBus
    Network
    Multimedia
)

ecm_find_qmlmodule(org.kde.plasma.core 2.0)
ecm_find_qmlmodule(Mycroft 1.0)
if(NOT ${Mycroft-QMLModule_FOUND})
    message(WARNING "Could not find the Mycroft QML module. Voice interaction features will not be available.")
endif()

ecm_set_disabled_deprecation_versions(QT 5.15.2
    KF 5.101
)


add_subdirectory(bin)
add_subdirectory(containments)
add_subdirectory(kcms)
add_subdirectory(components)
add_subdirectory(sounds)

plasma_install_package(shell org.kde.plasma.mycroft.bigscreen shells)
plasma_install_package(lookandfeel org.kde.plasma.mycroft.bigscreen look-and-feel lookandfeel)


install(FILES bin/mycroft-skill-launcher.py DESTINATION ${KDE_INSTALL_BINDIR})
install(FILES org.kde.plasma.mycroft.bigscreen.metainfo.xml DESTINATION ${KDE_INSTALL_METAINFODIR})

include(KDEClangFormat)
include(KDEGitCommitHooks)
file(GLOB_RECURSE ALL_CLANG_FORMAT_SOURCE_FILES *.cpp *.h)
kde_clang_format(${ALL_CLANG_FORMAT_SOURCE_FILES})
kde_configure_git_pre_commit_hook(CHECKS CLANG_FORMAT)

ki18n_install(po)

feature_summary(WHAT ALL INCLUDE_QUIET_PACKAGES FATAL_ON_MISSING_REQUIRED_PACKAGES)
