/*
    SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

#include <KPluginFactory>
#include <KQuickConfigModule>

class AudioDevice : public KQuickConfigModule
{
    Q_OBJECT

public:
    explicit AudioDevice(QObject *parent, const KPluginMetaData &data, const QVariantList &args)
        : KQuickConfigModule(parent, data, args)
    {
        setButtons(Apply | Default);
    }
};

K_PLUGIN_CLASS_WITH_JSON(AudioDevice, "kcm_mediacenter_audiodevice.json")

#include "audiodevice.moc"
