/*
 *   SPDX-FileCopyrightText: 2019-2020 Marco Martin <mart@kde.org>
 *
 *   SPDX-License-Identifier: GPL-2.0-or-later OR GPL-3.0-or-later OR LicenseRef-KDE-Accepted-GPL
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
