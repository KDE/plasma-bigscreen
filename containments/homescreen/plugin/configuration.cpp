/*
    SPDX-FileCopyrightText: 2016 Aditya Mehra <aix.m@outlook.com>
    SPDX-License-Identifier: LGPL-2.0-or-later
*/

#include "configuration.h"

#include <KConfigGroup>
#include <KSharedConfig>
#include <KUser>

Configuration &Configuration::self()
{
    static Configuration c;
    return c;
}

bool Configuration::mycroftEnabled() const
{
    static KSharedConfigPtr config = KSharedConfig::openConfig(QLatin1String("bigscreen"));
    static KConfigGroup grp(config, QLatin1String("General"));

    if (grp.isValid()) {
        return grp.readEntry(QLatin1String("MycroftEnabled"), true);
    }

    return true;
}

void Configuration::setMycroftEnabled(bool mycroftEnabled)
{
    KSharedConfigPtr config = KSharedConfig::openConfig(QLatin1String("bigscreen"));
    KConfigGroup grp(config, QLatin1String("General"));

    if (grp.isValid()) {
        grp.writeEntry(QLatin1String("MycroftEnabled"), mycroftEnabled);
        grp.sync();
        Q_EMIT mycroftEnabledChanged();
    }
}

bool Configuration::pmInhibitionEnabled() const
{
    static KSharedConfigPtr config = KSharedConfig::openConfig(QLatin1String("bigscreen"));
    static KConfigGroup grp(config, QLatin1String("General"));

    if (grp.isValid()) {
        return grp.readEntry(QLatin1String("PowerInhibition"), true);
    }

    return true;
}

void Configuration::setPmInhibitionEnabled(bool pmInhibitionEnabled)
{
    KSharedConfigPtr config = KSharedConfig::openConfig(QLatin1String("bigscreen"));
    KConfigGroup grp(config, QLatin1String("General"));

    if (grp.isValid()) {
        grp.writeEntry(QLatin1String("PowerInhibition"), pmInhibitionEnabled);
        grp.sync();
        Q_EMIT pmInhibitionEnabledChanged();
    }
}
