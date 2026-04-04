// SPDX-FileCopyrightText: 2023-2025 Devin Lin <devin@kde.org>
// SPDX-FileCopyrightText: 2024 Luis Büchi <luis.buechi@kdemail.net>
// SPDX-FileCopyrightText: 2025 Seshan Ravikumar <seshan@sineware.ca>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <utility>

#include <QMap>
#include <QString>
#include <QVariant>

#include <KConfigGroup>
#include <KSharedConfig>

// plasma-bigscreen/kdeglobals
// NOTE: we only write these entries if they are not already defined in the config
const QMap<QString, QMap<QString, QVariant>> APPLICATIONS_BLACKLIST_DEFAULT_SETTINGS = {
    {
        "Applications",
        {{
             "blacklist",
             "waydroid.com.android.calculator2,waydroid.com.android.camera2,waydroid.com.android.contacts,waydroid.com.android.deskclock,"
             "waydroid.com.android.documentsui,waydroid.com.android.gallery3d,waydroid.com.android.inputmethod.latin,"
             "waydroid.com.android.settings,waydroid.org.lineageos.eleven,waydroid.org.lineageos.etar,waydroid.org.lineageos.jelly,"
             "waydroid.org.lineageos.recorder,org.kde.drkonqi.coredump.gui,org.kde.kdeconnect.app,org.kde.kdeconnect.sms,"
             "plasma-bigscreen-swap-session"
        }}
    }
};

const QMap<QString, QMap<QString, QVariant>> KDEGLOBALS_DEFAULT_SETTINGS = {{"General", {{"BrowserApplication", "aura-browser"}}}};

const QMap<QString, QMap<QString, QVariant>> KDEGLOBALS_SETTINGS = {{"KDE", {{"LookAndFeelPackage", "org.kde.plasma.bigscreen"}}}};

// plasma-bigscreen/plasma-keyboardrc
const QMap<QString, QMap<QString, QVariant>> PLASMAKEYBOARDRC_SETTINGS = {{"General", {{"keyboardNavigationEnabled", true}}}};

// plasma-bigscreen/kwinrc
const QMap<QString, QMap<QString, QVariant>> KWINRC_DEFAULT_SETTINGS = {
    {"Wayland", {{"InputMethod", "/usr/share/applications/org.kde.plasma.keyboard.desktop"}}}};

QMap<QString, QMap<QString, QVariant>> getKwinrcSettings(KSharedConfig::Ptr m_bigscreenConfig)
{
    auto group = KConfigGroup{m_bigscreenConfig, QStringLiteral("General")};
    bool windowDecorationsEnabled = group.readEntry("windowDecorationsEnabled", false);

    return {{"Windows",
             {{"BorderlessMaximizedWindows", !windowDecorationsEnabled}, // whether to turn off window decorations
              {"Placement", "Maximizing"}, // maximize all windows
              {"InteractiveWindowMoveEnabled", false}}},
            {"Plugins",
             {
                 {"blurEnabled", false}, // disable blur plugin for performance
                 {"gamecontrollerEnabled", false} // disable gamecontroller plugin to do our own handling
             }},
            {"org.kde.kdecoration2",
             {
                 {"NoPlugin", false} // ensure that the window decoration plugin is always enabled, otherwise we get Qt default window decorations
             }},
            {"Wayland",
             {
                 {"VirtualKeyboardEnabled", true} // enable vkbd
             }},
            {"Input", {{"TabletMode", "off"}}}};
}

// Have a separate list here because we need to trigger DBus calls to load/unload each effect/script.
// Make sure that the effect/script is added to the kwinrc "Plugins" section above!
const QList<QString> KWIN_EFFECTS = {};
const QList<QString> KWIN_SCRIPTS = {};

// plasma-mobile/ksmserver
const QMap<QString, QMap<QString, QVariant>> KSMSERVER_SETTINGS = {{"General", {{"loginMode", "emptySession"}}}};
