/*
    SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

#include "kdeconnect.h"

#include <KAboutData>
#include <KLocalizedString>
#include <KPluginFactory>
#include <KSharedConfig>

static const QString configFile = QStringLiteral("plasma-localerc");
static const QString lcLanguage = QStringLiteral("LANGUAGE");

KdeConnect::KdeConnect(QObject *parent, const QVariantList &args)
    : KQuickAddons::ConfigModule(parent, args)
{
    KAboutData *about = new KAboutData(QStringLiteral("kcm_mediacenter_kdeconnect"), //
                                       i18n("Configure KDE Connect"),
                                       QStringLiteral("2.0"),
                                       QString(),
                                       KAboutLicense::LGPL);
    setAboutData(about);

    setButtons(Apply | Default);
}

KdeConnect::~KdeConnect()
{
}

void KdeConnect::load()
{
}

void KdeConnect::save()
{
}

void KdeConnect::defaults()
{
}

K_PLUGIN_CLASS_WITH_JSON(KdeConnect, "mediacenter_kdeconnect.json")

#include "kdeconnect.moc"
