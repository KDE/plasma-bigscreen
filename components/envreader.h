/*
    SPDX-FileCopyrightText: 2021 Aditya Mehra <aix.m@outlook.com>

    SPDX-License-Identifier: MIT
*/

#ifndef ENVREADER_H
#define ENVREADER_H

#include <QObject>
#include <QVariant>
#include "bigscreenplugin_dbus.h"

class EnvReader : public QObject
{
        Q_OBJECT

public:
        explicit EnvReader(QObject *parent = Q_NULLPTR);

public Q_SLOTS:
        QString getValue(const QString &name);
        void kScreenConfChange();

Q_SIGNALS:
        void configChangeReceived();

private:
        BigscreenDbusAdapterInterface* m_bigscreenDbusAdapterInterface;
};

#endif // ENVREADER_H
