/*
    SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

#ifndef AUDIODEVICE_H
#define AUDIODEVICE_H

#include <KQuickAddons/ConfigModule>

#include <KConfigGroup>

class AudioDevice : public KQuickAddons::ConfigModule
{
    Q_OBJECT

public:
    explicit AudioDevice(QObject *parent = nullptr, const QVariantList &list = QVariantList());
    ~AudioDevice() override;

public Q_SLOTS:
    void load() override;
    void save() override;
    void defaults() override;

private:
};

#endif
