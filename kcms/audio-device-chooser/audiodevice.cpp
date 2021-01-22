/*
 *   SPDX-FileCopyrightText: 2019-2020 Marco Martin <mart@kde.org>
 *
 *   SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */


#include "audiodevice.h"

#include <KAboutData>
#include <KLocalizedString>
#include <KPluginFactory>
#include <KSharedConfig>

static const QString configFile = QStringLiteral("plasma-localerc");
static const QString lcLanguage = QStringLiteral("LANGUAGE");

AudioDevice::AudioDevice(QObject *parent, const QVariantList &args)
    : KQuickAddons::ConfigModule(parent, args)
{
    KAboutData *about = new KAboutData(QStringLiteral("kcm_audiodevice"),
        i18n("Configure Plasma audiodevice"),
        QStringLiteral("2.0"), QString(), KAboutLicense::LGPL);
    setAboutData(about);

    setButtons(Apply | Default);
}

AudioDevice::~AudioDevice()
{
}

void AudioDevice::load()
{
}

void AudioDevice::save()
{
}

void AudioDevice::defaults()
{
}

K_PLUGIN_CLASS_WITH_JSON(AudioDevice, "kcm_audiodevice.json")

#include "audiodevice.moc"
