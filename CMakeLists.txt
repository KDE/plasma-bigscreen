# SPDX-FileCopyrightText: 2019 Aditya Mehra <aix.m@outlook.com>
# SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

# Set minimum CMake version (required for CMake 3.0 or later)
cmake_minimum_required(VERSION 3.24)

project(plasma-bigscreen)
set(PROJECT_VERSION "6.5.80")

set(QT_MIN_VERSION "6.9.0")
set(KF_MIN_VERSION "6.14.0")
set(QCORO_MIN_VERSION "0.7.0")

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Use Extra CMake Modules (ECM) for common functionality.
# See http://api.kde.org/ecm/manual/ecm.7.html
# and http://api.kde.org/ecm/manual/ecm-kde-modules.7.html
find_package(ECM ${KF_MIN_VERSION} REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH} ${CMAKE_MODULE_PATH})

include(ECMFindQmlModule)
include(KDEInstallDirs)
include(KDECMakeSettings)
include(KDECompilerSettings NO_POLICY_SCOPE)
include(ECMOptionalAddSubdirectory)
include(ECMInstallIcons)
include(ECMDeprecationSettings)
include(GenerateExportHeader)
include(KDEGitCommitHooks)
include(KDEClangFormat)
include(FeatureSummary)
include(ECMQmlModule)

remove_definitions(-DQT_NO_CAST_FROM_ASCII)

find_package(KF6 ${KF_MIN_VERSION} REQUIRED COMPONENTS
    BluezQt
    I18n
    Kirigami
    KCMUtils
    GlobalAccel
    Notifications
    KIO
    WindowSystem
    Svg
    DBusAddons
    IconThemes
)

find_package(KF6Screen CONFIG REQUIRED)
find_package(Plasma ${PROJECT_VERSION} REQUIRED)
find_package(PlasmaActivities ${PROJECT_VERSION} REQUIRED)
find_package(PlasmaActivitiesStats ${PROJECT_VERSION} REQUIRED)

find_package(LibKWorkspace 5.19 CONFIG REQUIRED)

find_package(Qt6 ${QT_MIN_VERSION} CONFIG REQUIRED COMPONENTS
    Quick
    Core
    Qml
    DBus
    Network
    Multimedia
    WebEngineCore
    WebEngineQuick
    WaylandClient
)
find_package(QCoro6 ${QCORO_MIN_VERSION} REQUIRED COMPONENTS Core Quick Qml)

find_package(PlasmaWaylandProtocols REQUIRED)
find_package(Wayland REQUIRED COMPONENTS Client)

# libcec (TV Remote support)
pkg_check_modules(Libcec IMPORTED_TARGET libcec>=6)
add_feature_info(Libcec Libcec_FOUND "Adds support for CEC devices (ex. TV Remotes)")

# SDL3 (Game controller support)
find_package(SDL3 REQUIRED)
set_package_properties(SDL3 PROPERTIES
        TYPE REQUIRED
        PURPOSE "Required for game controller support"
)

add_definitions(-DQT_NO_FOREACH -DQT_NO_URL_CAST_FROM_STRING)
kde_enable_exceptions()
qcoro_enable_coroutines()

add_subdirectory(bin)
add_subdirectory(containments)
add_subdirectory(kcms)
add_subdirectory(components)
add_subdirectory(sounds)
add_subdirectory(envmanager)
add_subdirectory(uvcviewer)
add_subdirectory(settingsapp)
add_subdirectory(webapp-viewer)
add_subdirectory(inputhandler)
add_subdirectory(kded)

plasma_install_package(shell org.kde.plasma.bigscreen shells)
plasma_install_package(lookandfeel org.kde.plasma.bigscreen look-and-feel lookandfeel)

install(FILES org.kde.plasma.bigscreen.metainfo.xml DESTINATION ${KDE_INSTALL_METAINFODIR})

file(GLOB_RECURSE ALL_CLANG_FORMAT_SOURCE_FILES *.cpp *.h)
kde_clang_format(${ALL_CLANG_FORMAT_SOURCE_FILES})
kde_configure_git_pre_commit_hook(CHECKS CLANG_FORMAT)

ki18n_install(po)

feature_summary(WHAT ALL INCLUDE_QUIET_PACKAGES FATAL_ON_MISSING_REQUIRED_PACKAGES)
