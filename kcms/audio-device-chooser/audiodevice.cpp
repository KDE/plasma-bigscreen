/*
    SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: LGPL-2.0-or-later
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
    KAboutData *about = new KAboutData(QStringLiteral("kcm_mediacenter_audiodevice"), //
                                       i18n("Configure Plasma Audio"),
                                       QStringLiteral("2.0"),
                                       QString(),
                                       KAboutLicense::LGPL);
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

K_PLUGIN_CLASS_WITH_JSON(AudioDevice, "kcm_mediacenter_audiodevice.json")

#include "audiodevice.moc"
