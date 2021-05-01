/*
 *  Copyright (C) 2019 Marco MArtin <mart@kde.org>
 *
 *  This library is free software; you can redistribute it and/or
 *  modify it under the terms of the GNU Library General Public
 *  License as published by the Free Software Foundation; either
 *  version 2 of the License, or (at your option) any later version.
 *
 *  This library is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 *  Library General Public License for more details.
 *
 *  You should have received a copy of the GNU Library General Public License
 *  along with this library; see the file COPYING.LIB.  If not, write to
 *  the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 *  Boston, MA 02110-1301, USA.
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
    KAboutData *about = new KAboutData(QStringLiteral("kcm_audiodevice"), //
                                       i18n("Configure Plasma audiodevice"),
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

K_PLUGIN_CLASS_WITH_JSON(AudioDevice, "kcm_audiodevice.json")

#include "audiodevice.moc"
