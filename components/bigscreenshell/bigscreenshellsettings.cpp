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
