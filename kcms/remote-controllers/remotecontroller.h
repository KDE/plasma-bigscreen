/*
    SPDX-FileCopyrightText: 2022 Aditya Mehra <aix.m@outlook.com>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

#ifndef RemoteControllers_H
#define RemoteControllers_H

#include <KQuickAddons/ConfigModule>

#include <KConfigGroup>

class RemoteController : public KQuickAddons::ConfigModule
{
    Q_OBJECT

public:
    explicit RemoteController(QObject *parent = nullptr, const QVariantList &list = QVariantList());
    ~RemoteController() override;

public Q_SLOTS:
    void load() override;
    void save() override;
    void defaults() override;

    QString getCecKeyConfig(const QString key);
    void setCecKeyConfig(const QString button, const QString key);

    int getCecKeyFromRemotePress();

Q_SIGNALS:
    void cecConfigChanged(const QString button);

private:
};

#endif
