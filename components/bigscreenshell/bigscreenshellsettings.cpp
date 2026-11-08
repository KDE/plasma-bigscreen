// SPDX-FileCopyrightText: 2026 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "bigscreenshellsettings.h"

#include <KIO/CommandLauncherJob>
#include <KNotificationJobUiDelegate>
#include <QDebug>

const QString CONFIG_FILE = QStringLiteral("plasmabigscreenrc");
const QString GENERAL_CONFIG_GROUP = QStringLiteral("General");

BigscreenShellSettings::BigscreenShellSettings(QObject *parent)
    : QObject{parent}
    , m_config{KSharedConfig::openConfig(CONFIG_FILE)}
{
    m_configWatcher = KConfigWatcher::create(m_config);
    connect(m_configWatcher.data(), &KConfigWatcher::configChanged, this, [this](const KConfigGroup &group, const QByteArrayList &names) -> void {
        Q_UNUSED(names)
        if (group.name() == GENERAL_CONFIG_GROUP) {
            Q_EMIT pmInhibitionEnabledChanged();
            Q_EMIT navigationSoundEnabledChanged();
            Q_EMIT windowDecorationsEnabledChanged();
            Q_EMIT navigationRumbleIntensityChanged();
            Q_EMIT useLinkRedirectorChanged();
            Q_EMIT defaultBrowserChanged();
        }
    });
}

bool BigscreenShellSettings::pmInhibitionEnabled() const
{
    auto group = KConfigGroup{m_config, GENERAL_CONFIG_GROUP};
    return group.readEntry("pmInhibitionEnabled", true);
}

void BigscreenShellSettings::setPmInhibitionEnabled(bool pmInhibitionEnabled)
{
    auto group = KConfigGroup{m_config, GENERAL_CONFIG_GROUP};
    group.writeEntry("pmInhibitionEnabled", pmInhibitionEnabled, KConfigGroup::Notify);
    m_config->sync();
}

bool BigscreenShellSettings::navigationSoundEnabled() const
{
    auto group = KConfigGroup{m_config, GENERAL_CONFIG_GROUP};
    return group.readEntry("navigationSoundEnabled", false);
}

void BigscreenShellSettings::setNavigationSoundEnabled(bool navigationSoundEnabled)
{
    auto group = KConfigGroup{m_config, GENERAL_CONFIG_GROUP};
    group.writeEntry("navigationSoundEnabled", navigationSoundEnabled, KConfigGroup::Notify);
    m_config->sync();
}

bool BigscreenShellSettings::windowDecorationsEnabled() const
{
    auto group = KConfigGroup{m_config, GENERAL_CONFIG_GROUP};
    return group.readEntry("windowDecorationsEnabled", false);
}

void BigscreenShellSettings::setWindowDecorationsEnabled(bool windowDecorationsEnabled)
{
    auto group = KConfigGroup{m_config, GENERAL_CONFIG_GROUP};
    group.writeEntry("windowDecorationsEnabled", windowDecorationsEnabled, KConfigGroup::Notify);
    m_config->sync();

    // Update environment settings
    auto *job = new KIO::CommandLauncherJob(QStringLiteral("plasma-bigscreen-envmanager --apply-settings"), {});
    job->setUiDelegate(new KNotificationJobUiDelegate(KJobUiDelegate::AutoErrorHandlingEnabled));
    job->setDesktopName(QStringLiteral("org.kde.plasma-bigscreen-envmanager"));
    job->start();
}

int BigscreenShellSettings::navigationRumbleIntensity() const
{
    auto group = KConfigGroup{m_config, GENERAL_CONFIG_GROUP};
    return group.readEntry("navigationRumbleIntensity", 0);
}

void BigscreenShellSettings::setNavigationRumbleIntensity(int navigationRumbleIntensity)
{
    auto group = KConfigGroup{m_config, GENERAL_CONFIG_GROUP};
    static constexpr int NUM_SETTINGS = 4;
    group.writeEntry("navigationRumbleIntensity", qBound(0, navigationRumbleIntensity, NUM_SETTINGS - 1), KConfigGroup::Notify);
    m_config->sync();
}

bool BigscreenShellSettings::useLinkRedirector() const
{
    auto group = KConfigGroup{m_config, GENERAL_CONFIG_GROUP};
    return group.readEntry("useLinkRedirector", false);
}

void BigscreenShellSettings::setUseLinkRedirector(const bool useLinkRedirector)
{
    KSharedConfig::Ptr mimeapps = KSharedConfig::openConfig(QStringLiteral("mimeapps.list"), KConfig::NoCascade, QStandardPaths::GenericConfigLocation);
    auto mimeappsGroup = KConfigGroup{mimeapps, QStringLiteral("Default Applications")};
    auto bigscreenGroup = KConfigGroup{m_config, GENERAL_CONFIG_GROUP};
    
    if (useLinkRedirector) {
        setDefaultBrowser(defaultBrowser());
        mimeappsGroup.writeEntry("x-scheme-handler/http", QStringLiteral("org.kde.plasma.bigscreen.linkredirector"));
        mimeappsGroup.writeEntry("x-scheme-handler/https", QStringLiteral("org.kde.plasma.bigscreen.linkredirector"));
    } else {
        QString browser = defaultBrowser(); 
        mimeappsGroup.writeEntry("x-scheme-handler/http", browser);
        mimeappsGroup.writeEntry("x-scheme-handler/https", browser);
    }

    bigscreenGroup.writeEntry("useLinkRedirector", useLinkRedirector, KConfigGroup::Notify);
    m_config->sync();
}

QString BigscreenShellSettings::defaultBrowser() const
{
    if (useLinkRedirector()){
        auto group = KConfigGroup{m_config, GENERAL_CONFIG_GROUP};
        return group.readEntry("defaultBrowser", QStringLiteral("org.kde.aura-browser"));
    } else {
        KSharedConfig::Ptr mimeapps = KSharedConfig::openConfig(QStringLiteral("mimeapps.list"), KConfig::NoCascade, QStandardPaths::GenericConfigLocation);
        auto group = KConfigGroup{mimeapps, QStringLiteral("Default Applications")};
        return group.readEntry("x-scheme-handler/https", group.readEntry("x-scheme-handler/http", QStringLiteral("org.kde.aura-browser")));
    }
}

void BigscreenShellSettings::setDefaultBrowser(const QString defaultBrowser)
{
    if (useLinkRedirector()) {
        auto group = KConfigGroup{m_config, GENERAL_CONFIG_GROUP};
        group.writeEntry("defaultBrowser", defaultBrowser, KConfigGroup::Notify);
        m_config->sync();
    } else {
        KSharedConfig::Ptr mimeapps = KSharedConfig::openConfig(QStringLiteral("mimeapps.list"), KConfig::NoCascade, QStandardPaths::GenericConfigLocation);
        auto group = KConfigGroup{mimeapps, QStringLiteral("Default Applications")};
        group.writeEntry("x-scheme-handler/http", defaultBrowser, KConfigGroup::Notify);
        group.writeEntry("x-scheme-handler/https", defaultBrowser, KConfigGroup::Notify);
        mimeapps->sync();
    }
}