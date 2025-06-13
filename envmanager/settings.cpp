// SPDX-FileCopyrightText: 2023-2025 Devin Lin <devin@kde.org>
// SPDX-FileCopyrightText: 2024 Luis Büchi <luis.buechi@kdemail.net>
// SPDX-FileCopyrightText: 2025 Seshan Ravikumar <seshan@sineware.ca>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "settings.h"
#include "config.h"
#include "utils.h"

#include <KRuntimePlatform>

#include <QDBusConnection>
#include <QDBusMessage>
#include <QDebug>
#include <QProcess>

using namespace Qt::Literals::StringLiterals;

// In bin/startplasma-bigscreen, we add `~/.config/plasma-bigscreen` to XDG_CONFIG_DIRS to overlay our own configs
const QString BIGSCREEN_KWINRC_FILE = u"plasma-bigscreen/kwinrc"_s;
const QString BIGSCREEN_KSMSERVERRC_FILE = u"plasma-bigscreen/ksmserverrc"_s;
const QString BIGSCREEN_KDEGLOBALS_FILE = u"plasma-bigscreen/kdeglobals"_s;

Settings::Settings(QObject *parent)
    : QObject{parent}
    , m_isMediacenterPlatform{KRuntimePlatform::runtimePlatform().contains(u"mediacenter"_s)}
{
}

Settings &Settings::self()
{
    static Settings settings;
    return settings;
}

void Settings::applyConfiguration()
{
    if (!m_isMediacenterPlatform) {
        qCDebug(LOGGING_CATEGORY) << "Configuration will not be applied, as the session is not Mediacenter/Plasma Bigscreen.";
        return;
    }

    qCDebug(LOGGING_CATEGORY) << "Checking and applying bigscreen configuration...";
    applyBigscreenConfiguration();
}

void Settings::applyBigscreenConfiguration()
{
    // kwinrc
    {
        setOptionsImmutable(false, BIGSCREEN_KWINRC_FILE, KWINRC_SETTINGS);

        auto kwinrc = kwinrcConfig();
        writeKeys(BIGSCREEN_KWINRC_FILE, kwinrc, KWINRC_SETTINGS);
        kwinrc->sync();
        reloadKWinConfig();

        setOptionsImmutable(true, BIGSCREEN_KWINRC_FILE, KWINRC_SETTINGS);
    }

    // kdeglobals
    {
        setOptionsImmutable(false, BIGSCREEN_KDEGLOBALS_FILE, KDEGLOBALS_SETTINGS);

        auto kdeglobals = KSharedConfig::openConfig(BIGSCREEN_KDEGLOBALS_FILE, KConfig::SimpleConfig);
        writeKeys(u"kdeglobals"_s, kdeglobals, KDEGLOBALS_DEFAULT_SETTINGS);
        writeKeys(u"kdeglobals"_s, kdeglobals, KDEGLOBALS_SETTINGS);
        kdeglobals->sync();

        setOptionsImmutable(true, BIGSCREEN_KDEGLOBALS_FILE, KDEGLOBALS_SETTINGS);
    }

    // ksmserver
    {
        setOptionsImmutable(false, BIGSCREEN_KSMSERVERRC_FILE, KSMSERVER_SETTINGS);

        auto ksmserver = KSharedConfig::openConfig(BIGSCREEN_KSMSERVERRC_FILE, KConfig::SimpleConfig);
        writeKeys(BIGSCREEN_KSMSERVERRC_FILE, ksmserver, KSMSERVER_SETTINGS);
        ksmserver->sync();

        setOptionsImmutable(true, BIGSCREEN_KSMSERVERRC_FILE, KSMSERVER_SETTINGS);
    }
}

void Settings::writeKeys(const QString &fileName, KSharedConfig::Ptr &config, const QMap<QString, QMap<QString, QVariant>> &settings)
{
    const auto groupNames = settings.keys();
    for (const auto &groupName : groupNames) {
        auto group = KConfigGroup{config, groupName};

        const auto keys = settings[groupName].keys();
        for (const auto &key : keys) {
            group.writeEntry(key, settings[groupName][key], KConfigGroup::Notify);
        }
    }
}

KSharedConfig::Ptr Settings::kwinrcConfig() const
{
    return KSharedConfig::openConfig(BIGSCREEN_KWINRC_FILE, KConfig::SimpleConfig);
}

void Settings::reloadKWinConfig()
{
    // Reload config
    QDBusMessage reloadMessage = QDBusMessage::createSignal("/KWin", "org.kde.KWin", "reloadConfig");
    QDBusConnection::sessionBus().send(reloadMessage);

    // Effects need to manually be loaded/unloaded in a live KWin session.

    KConfigGroup pluginsGroup{kwinrcConfig(), QStringLiteral("Plugins")};

    for (const auto &effect : KWIN_EFFECTS) {
        // Read from the config whether the effect is enabled (settings are suffixed with "Enabled", ex. blurEnabled)
        bool status = pluginsGroup.readEntry(effect + u"Enabled"_s, false);
        const QString method = status ? u"loadEffect"_s : u"unloadEffect"_s;

        QDBusMessage message = QDBusMessage::createMethodCall(u"org.kde.KWin"_s, u"/Effects"_s, u"org.kde.kwin.Effects"_s, method);
        message.setArguments({effect});
        QDBusConnection::sessionBus().send(message);
    }

    // Unload KWin scripts that are now disabled.
    for (const auto &script : KWIN_SCRIPTS) {
        // Read from the config whether the effect is enabled (settings are suffixed with "Enabled", ex. blurEnabled)
        bool status = pluginsGroup.readEntry(script + u"Enabled"_s, false);

        if (!status) {
            QDBusMessage message = QDBusMessage::createMethodCall(u"org.kde.KWin"_s, u"/Scripting"_s, u"org.kde.kwin.Scripting"_s, u"unloadScript"_s);
            message.setArguments({script});
            QDBusConnection::sessionBus().send(message);
        }
    }

    // Call "start" to load enabled KWin scripts.
    QDBusMessage message = QDBusMessage::createMethodCall(u"org.kde.KWin"_s, u"/Scripting"_s, u"org.kde.kwin.Scripting"_s, u"start"_s);
    QDBusConnection::sessionBus().send(message);

    // Call reconfigure
    QDBusMessage reconfigureMessage = QDBusMessage::createSignal("/KWin", "org.kde.KWin", "reconfigure");
    QDBusConnection::sessionBus().send(reconfigureMessage);
}
