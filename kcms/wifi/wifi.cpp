/*
    SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

#include "wifi.h"

#include <KAboutData>
#include <KLocalizedString>
#include <KPluginFactory>
#include <KSharedConfig>

static const QString configFile = QStringLiteral("plasma-localerc");
static const QString lcLanguage = QStringLiteral("LANGUAGE");

Wifi::Wifi(QObject *parent, const QVariantList &args)
    : KQuickAddons::ConfigModule(parent, args)
{
    KAboutData *about = new KAboutData(QStringLiteral("kcm_mediacenter_wifi"), //
                                       i18n("Configure Plasma wifi"),
                                       QStringLiteral("2.0"),
                                       QString(),
                                       KAboutLicense::LGPL);
    setAboutData(about);

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
