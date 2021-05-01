/*
    SPDX-FileCopyrightText: 2016 Aditya Mehra <aix.m@outlook.com>
    SPDX-License-Identifier: LGPL-2.0-or-later
*/

#include "biglauncher_dbus.h"
#include <QByteArray>
#include <QList>
#include <QMap>
#include <QMetaObject>
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
