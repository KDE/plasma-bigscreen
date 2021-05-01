/*
    SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

#ifndef WIFI_H
#define WIFI_H

#include <KQuickAddons/ConfigModule>

#include <KConfigGroup>

class KdeConnect : public KQuickAddons::ConfigModule
{
    Q_OBJECT

public:
    explicit KdeConnect(QObject *parent = nullptr, const QVariantList &list = QVariantList());
    ~KdeConnect() override;

public Q_SLOTS:
    void load() override;
    void save() override;
    void defaults() override;

private:
};

#endif
