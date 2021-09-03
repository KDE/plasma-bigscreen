/*
    SPDX-FileCopyrightText: 2021 Aditya Mehra <aix.m@outlook.com>

    SPDX-License-Identifier: MIT
*/

#include "envreader.h"
#include <QtDBus>
#include <QDBusInterface>

EnvReader::EnvReader(QObject *parent)
    : QObject(parent)
{
}

QString EnvReader::getValue(const QString &name)
{
    return qgetenv(qPrintable(name));
}

void EnvReader::kScreenConfChange()
{
    emit configChangeReceived();
}

void EnvReader::createInterface()
{
    if(QDBusConnection::sessionBus().interface()->isServiceRegistered(QStringLiteral("org.kde.KScreen"))){
        bool connection = QDBusConnection::sessionBus().connect("org.kde.KScreen", "/backend", "org.kde.kscreen.Backend", "configChanged", this, SLOT(kScreenConfChange()));
        if (!connection){
            qWarning() << "Connection Failed";
        }
    }
}
