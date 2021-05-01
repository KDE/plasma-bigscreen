/*
    SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

#ifndef WIFI_H
#define WIFI_H

#include <KQuickAddons/ConfigModule>

#include <KConfigGroup>

class Wifi : public KQuickAddons::ConfigModule
{
    Q_OBJECT

public:
    explicit Wifi(QObject *parent = nullptr, const QVariantList &list = QVariantList());
    ~Wifi() override;

public Q_SLOTS:
    void load() override;
    void save() override;
    void defaults() override;

private:
};

#endif
