// SPDX-FileCopyrightText: 2023-2025 Devin Lin <devin@kde.org>
// SPDX-FileCopyrightText: 2024 Luis Büchi <luis.buechi@kdemail.net>
// SPDX-FileCopyrightText: 2025 Seshan Ravikumar <seshan@sineware.ca>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <QObject>

#include <KConfigGroup>
#include <KSharedConfig>

class Settings : public QObject
{
    Q_OBJECT

public:
    Settings(QObject *parent = nullptr);
    static Settings &self();

    // apply the configuration
    void applyConfiguration();

private:
    // applies our bigscreen configuration
    void applyBigscreenConfiguration();

    void writeKeys(const QString &fileName, KSharedConfig::Ptr &config, const QMap<QString, QMap<QString, QVariant>> &settings);

    KSharedConfig::Ptr kwinrcConfig() const;
    void reloadKWinConfig();

    // whether this is Plasma Bigscreen
    bool m_isMediacenterPlatform;
};
