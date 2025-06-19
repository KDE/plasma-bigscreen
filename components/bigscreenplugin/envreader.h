/*
    SPDX-FileCopyrightText: 2021 Aditya Mehra <aix.m@outlook.com>

    SPDX-License-Identifier: MIT
*/

#ifndef ENVREADER_H
#define ENVREADER_H

#include "bigscreenplugin_dbus.h"
#include <QObject>
#include <QVariant>
#include <qqmlregistration.h>

class EnvReader : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

public:
    explicit EnvReader(QObject *parent = nullptr);

public Q_SLOTS:
    QString getValue(const QString &name);
    void kScreenConfChange();

Q_SIGNALS:
    void configChangeReceived();

private:
    BigscreenDbusAdapterInterface *m_bigscreenDbusAdapterInterface;
};

#endif // ENVREADER_H
