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
    Q_PROPERTY(bool windowDecorationsEnabled READ windowDecorationsEnabled WRITE setWindowDecorationsEnabled NOTIFY windowDecorationsEnabledChanged)

public:
    BigscreenShellSettings(QObject *parent = nullptr);

    bool pmInhibitionEnabled() const;
    void setPmInhibitionEnabled(bool pmInhibitionEnabled);

    bool navigationSoundEnabled() const;
    void setNavigationSoundEnabled(bool navigationSoundEnabled);

    bool windowDecorationsEnabled() const;
    void setWindowDecorationsEnabled(bool windowDecorationsEnabled);

Q_SIGNALS:
    void pmInhibitionEnabledChanged();
    void navigationSoundEnabledChanged();
    void windowDecorationsEnabledChanged();

private:
    KConfigWatcher::Ptr m_configWatcher;
    KSharedConfig::Ptr m_config;
};
