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
const QMap<QString, QMap<QString, QVariant>> KDEGLOBALS_DEFAULT_SETTINGS = {{"General", {{"BrowserApplication", "aura-browser"}}}};

const QMap<QString, QMap<QString, QVariant>> KDEGLOBALS_SETTINGS = {{"KDE", {{"LookAndFeelPackage", "org.kde.plasma.bigscreen"}}}};

// plasma-bigscreen/plasma-keyboardrc
const QMap<QString, QMap<QString, QVariant>> PLASMAKEYBOARDRC_SETTINGS = {{"General", {{"keyboardNavigationEnabled", true}}}};

// plasma-bigscreen/kwinrc
const QMap<QString, QMap<QString, QVariant>> KWINRC_DEFAULT_SETTINGS = {
    {"Wayland", {{"InputMethod", "/usr/share/applications/org.kde.plasma.keyboard.desktop"}}}};
const QMap<QString, QMap<QString, QVariant>> KWINRC_SETTINGS = {
    {"Windows",
     {{"Placement", "Maximizing"}, // maximize all windows by
      {"InteractiveWindowMoveEnabled", false}}},
    {"Plugins",
     {
         {"blurEnabled", false} // disable blur plugin for performance
     }},
    {"org.kde.kdecoration2",
     {
         {"NoPlugin", false} // leave window decorations plugin enabled for now, we don't have an easy way of exiting apps
     }},
    {"Input", {{"TabletMode", "off"}}}};

// Have a separate list here because we need to trigger DBus calls to load/unload each effect/script.
// Make sure that the effect/script is added to the kwinrc "Plugins" section above!
const QList<QString> KWIN_EFFECTS = {};
const QList<QString> KWIN_SCRIPTS = {};

// plasma-mobile/ksmserver
const QMap<QString, QMap<QString, QVariant>> KSMSERVER_SETTINGS = {{"General", {{"loginMode", "emptySession"}}}};
