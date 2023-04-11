/*
    SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

#ifndef KDECONNECT_H
#define KDECONNECT_H

#include <KQuickConfigModule>

#include <KConfigGroup>
#include <kpluginmetadata.h>

class KdeConnect : public KQuickConfigModule
{
    Q_OBJECT

public:
    explicit KdeConnect(QObject *parent, const KPluginMetaData &data, const QVariantList &list);
    ~KdeConnect() override;

public Q_SLOTS:
    void load() override;
    void save() override;
    void defaults() override;

private:
};

#endif // KDECONNECT_H