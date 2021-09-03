/*
    SPDX-FileCopyrightText: 2021 Aditya Mehra <aix.m@outlook.com>

    SPDX-License-Identifier: MIT
*/

#ifndef ENVREADER_H
#define ENVREADER_H

#include <QObject>
#include <QVariant>
#include <QDBusConnection>

class EnvReader : public QObject
{
        Q_OBJECT

public:
        explicit EnvReader(QObject *parent = Q_NULLPTR);

public Q_SLOTS:
        QString getValue(const QString &name);
        void createInterface();
        void kScreenConfChange();

Q_SIGNALS:
        void configChangeReceived();
};

#endif // ENVREADER_H
