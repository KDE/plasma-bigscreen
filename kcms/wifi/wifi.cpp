/*
    SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

#include "wifi.h"

#include <KAboutData>
#include <KLocalizedString>
#include <KPluginFactory>
#include <KSharedConfig>

Wifi::Wifi(QObject *parent, const KPluginMetaData &data, const QVariantList &args)
    : KQuickConfigModule(parent, data, args)
{
    setButtons(Apply | Default);
}

Wifi::~Wifi()
{
}

void Wifi::load()
{
}

void Wifi::save()
{
}

void Wifi::defaults()
{
}

K_PLUGIN_CLASS_WITH_JSON(Wifi, "mediacenter_wifi.json")

#include "wifi.moc"
