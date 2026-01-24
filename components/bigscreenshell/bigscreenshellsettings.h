// SPDX-FileCopyrightText: 2026 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <KConfigGroup>
#include <KConfigWatcher>
#include <KSharedConfig>
#include <QDBusConnection>
#include <QObject>
#include <qqmlregistration.h>

class BigscreenShellSettings : public QObject
{
    Q_OBJECT
    QML_NAMED_ELEMENT(Settings)
    QML_SINGLETON

    // general
    Q_PROPERTY(bool pmInhibitionEnabled READ pmInhibitionEnabled WRITE setPmInhibitionEnabled NOTIFY pmInhibitionEnabledChanged)
    Q_PROPERTY(bool navigationSoundEnabled READ navigationSoundEnabled WRITE setNavigationSoundEnabled NOTIFY navigationSoundEnabledChanged)

public:
    BigscreenShellSettings(QObject *parent = nullptr);

    bool pmInhibitionEnabled() const;
    void setPmInhibitionEnabled(bool pmInhibitionEnabled);

    bool navigationSoundEnabled() const;
    void setNavigationSoundEnabled(bool navigationSoundEnabled);

Q_SIGNALS:
    void pmInhibitionEnabledChanged();
    void navigationSoundEnabledChanged();

private:
    KConfigWatcher::Ptr m_configWatcher;
    KSharedConfig::Ptr m_config;
};
