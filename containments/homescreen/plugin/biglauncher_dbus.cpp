/*
 *   Copyright (C) 2016 by Aditya Mehra <aix.m@outlook.com>                      *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#include "biglauncher_dbus.h"
#include <QMetaObject>
#include <QByteArray>
#include <QList>
#include <QMap>
#include <QString>
#include <QStringList>
#include <QVariant>
#include <QtDBus>

/*
 * Implementation of adaptor class BigLauncherDbusAdapterInterface
 */

BigLauncherDbusAdapterInterface::BigLauncherDbusAdapterInterface(QObject *parent)
    : QDBusAbstractAdaptor(parent)
{
    // constructor
    QDBusConnection dbus = QDBusConnection::sessionBus();
    dbus.registerObject("/mycroftapplet", this, QDBusConnection::ExportScriptableSlots | QDBusConnection::ExportNonScriptableSlots);
    dbus.registerService("org.kde.mycroftapplet");
    setAutoRelaySignals(true);
}

BigLauncherDbusAdapterInterface::~BigLauncherDbusAdapterInterface()
{
    // destructor
}

void BigLauncherDbusAdapterInterface::showMycroft()
{
    // handle method call org.kde.mycroft.showMycroft
    emit sendShowMycroft("Show");
    QMetaObject::invokeMethod(this, "getMethod", Qt::DirectConnection, Q_ARG(QString, "Show"));
}

void BigLauncherDbusAdapterInterface::showSkills()
{
    // handle method call org.kde.mycroft.showSkills
    emit sendShowSkills("ShowSkills");
    QMetaObject::invokeMethod(this, "getMethod", Qt::DirectConnection, Q_ARG(QString, "ShowSkills"));
}

void BigLauncherDbusAdapterInterface::showSkillsInstaller()
{
    // handle method call org.kde.mycroft.showSkillsInstaller
    emit installList("ShowInstallSkills");
    QMetaObject::invokeMethod(this, "getMethod", Qt::DirectConnection, Q_ARG(QString, "ShowInstallSkills"));
}

void BigLauncherDbusAdapterInterface::showRecipeMethod(const QString &recipeName)
{
    // handle method call org.kde.mycroft.showRecipeMethod
    emit recipeMethod(recipeName);
    QMetaObject::invokeMethod(this, "getMethod", Qt::DirectConnection, Q_ARG(QString, recipeName));
}

void BigLauncherDbusAdapterInterface::sendKioMethod(const QString &kioString)
{
    // handle method call org.kde.mycroft.showRecipeMethod
    emit kioMethod(kioString);
    QMetaObject::invokeMethod(this, "getMethod", Qt::DirectConnection, Q_ARG(QString, kioString));
}

Q_INVOKABLE QString BigLauncherDbusAdapterInterface::getMethod(const QString &method)
{
    QString str = method;
    return str;
}

