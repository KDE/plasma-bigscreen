/*
    SPDX-FileCopyrightText: 2021 Aditya Mehra <aix.m@outlook.com>

    SPDX-License-Identifier: MIT
*/

#include "envreader.h"
#include "bigscreenplugin_dbus.h"

EnvReader::EnvReader(QObject *parent)
    : QObject(parent)
{
    m_bigscreenDbusAdapterInterface = new BigscreenDbusAdapterInterface(this);
    connect(m_bigscreenDbusAdapterInterface, &BigscreenDbusAdapterInterface::autoResolutionReceivedChange, this, &EnvReader::kScreenConfChange);
}

QString EnvReader::getValue(const QString &name)
{
    return qgetenv(qPrintable(name));
}

void EnvReader::kScreenConfChange()
{
    emit configChangeReceived();
}
