/*
    SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

#include "kdeconnect.h"

#include <KAboutData>
#include <KLocalizedString>
#include <KPluginFactory>
#include <KSharedConfig>

KdeConnect::KdeConnect(QObject *parent, const KPluginMetaData &data, const QVariantList &args)
    : KQuickConfigModule(parent, data, args)
{
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
