/*
    SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

#include <KPluginFactory>
#include <KQuickConfigModule>

class KdeConnect : public KQuickConfigModule
{
    Q_OBJECT
public:
    explicit KdeConnect(QObject *parent, const KPluginMetaData &data, const QVariantList &args)
        : KQuickConfigModule(parent, data, args)
    {
        setButtons(Apply | Default);
    }
};
K_PLUGIN_CLASS_WITH_JSON(KdeConnect, "mediacenter_kdeconnect.json")

#include "kdeconnect.moc"
