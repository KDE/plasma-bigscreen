/*
    SPDX-FileCopyrightText: 2016 Aditya Mehra <aix.m@outlook.com>
    SPDX-License-Identifier: LGPL-2.0-or-later
*/

#include "biglauncher_dbus.h"
#include "configuration.h"
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
    dbus.registerObject("/BigLauncher", this, QDBusConnection::ExportScriptableSlots | QDBusConnection::ExportNonScriptableSlots);
    dbus.registerService("org.kde.biglauncher");
    setAutoRelaySignals(true);
}

BigLauncherDbusAdapterInterface::~BigLauncherDbusAdapterInterface()
{
    // destructor
}

void BigLauncherDbusAdapterInterface::useColoredTiles(const bool &coloredTiles)
{
    emit useColoredTilesChanged(coloredTiles);
}

void BigLauncherDbusAdapterInterface::useExpandableTiles(const bool &expandableTiles)
{
    emit useExpandableTilesChanged(expandableTiles);
}

void BigLauncherDbusAdapterInterface::enableMycroftIntegration(const bool &mycroftIntegration)
{
    Configuration::self().setMycroftEnabled(mycroftIntegration);
    emit enableMycroftIntegrationChanged(mycroftIntegration);
}

void BigLauncherDbusAdapterInterface::enablePmInhibition(const bool &pmInhibition)
{
    Configuration::self().setPmInhibitionEnabled(pmInhibition);
    emit enablePmInhibitionChanged(pmInhibition);
}

bool BigLauncherDbusAdapterInterface::coloredTilesActive()
{
    if(m_useColoredTiles) {
        return 1;
    } else {
        return 0;
    }
}

bool BigLauncherDbusAdapterInterface::expandableTilesActive()
{
    if(m_useExpandableTiles) {
         return 1;
    } else {
        return 0;
    }
}

bool BigLauncherDbusAdapterInterface::mycroftIntegrationActive()
{
    return Configuration::self().mycroftEnabled();
}

bool BigLauncherDbusAdapterInterface::pmInhibitionActive()
{
    return Configuration::self().pmInhibitionEnabled();
}

void BigLauncherDbusAdapterInterface::setColoredTilesActive(const bool &coloredTilesActive)
{
    m_useColoredTiles = coloredTilesActive;
}

void BigLauncherDbusAdapterInterface::setExpandableTilesActive(const bool &expandableTilesActive)
{
    m_useExpandableTiles = expandableTilesActive;
}

Q_INVOKABLE QString BigLauncherDbusAdapterInterface::getMethod(const QString &method)
{
    QString str = method;
    return str;
}
