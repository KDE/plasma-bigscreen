/*
    SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

#include "audiodevice.h"

#include <KAboutData>
#include <KLocalizedString>
#include <KPluginFactory>
#include <KSharedConfig>

AudioDevice::AudioDevice(QObject *parent, const KPluginMetaData &data, const QVariantList &args)
    : KQuickConfigModule(parent, data, args)
{
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
