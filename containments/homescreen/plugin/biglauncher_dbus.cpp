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
#include <QVariant>
#include <QDBusMessage>

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

    m_shortcuts = Shortcuts::instance();
}

BigLauncherDbusAdapterInterface::~BigLauncherDbusAdapterInterface()
{
    // destructor
}

void BigLauncherDbusAdapterInterface::useColoredTiles(const bool &coloredTiles)
{
    Q_EMIT useColoredTilesChanged(coloredTiles);
}

void BigLauncherDbusAdapterInterface::useExpandableTiles(const bool &expandableTiles)
{
    Q_EMIT useExpandableTilesChanged(expandableTiles);
}

void BigLauncherDbusAdapterInterface::enablePmInhibition(const bool &pmInhibition)
{
    Configuration::self().setPmInhibitionEnabled(pmInhibition);
    Q_EMIT enablePmInhibitionChanged(pmInhibition);
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

QString BigLauncherDbusAdapterInterface::activateSettingsShortcut()
{
    return m_shortcuts->activateSettingsShortcut().toString();
}

QString BigLauncherDbusAdapterInterface::activateTasksShortcut()
{
    return m_shortcuts->activateTasksShortcut().toString();
}

QString BigLauncherDbusAdapterInterface::displayHomeScreenShortcut()
{
    return m_shortcuts->displayHomeScreenShortcut().toString();
}

void BigLauncherDbusAdapterInterface::setActivateSettingsShortcut(const QString &shortcut)
{
    QKeySequence seq = QKeySequence::fromString(shortcut);
    m_shortcuts->setActivateSettingsShortcut(seq);
}

void BigLauncherDbusAdapterInterface::setActivateTasksShortcut(const QString &shortcut)
{
    QKeySequence seq = QKeySequence::fromString(shortcut);
    m_shortcuts->setActivateTasksShortcut(seq);
}

void BigLauncherDbusAdapterInterface::setDisplayHomeScreenShortcut(const QString &shortcut)
{
    QKeySequence seq = QKeySequence::fromString(shortcut);
    m_shortcuts->setDisplayHomeScreenShortcut(seq);
}

void BigLauncherDbusAdapterInterface::resetActivateSettingsShortcut()
{
    m_shortcuts->resetActivateSettingsShortcut();
}

void BigLauncherDbusAdapterInterface::resetActivateTasksShortcut()
{
    m_shortcuts->resetActivateTasksShortcut();
}

void BigLauncherDbusAdapterInterface::resetDisplayHomeScreenShortcut()
{
    m_shortcuts->resetDisplayHomeScreenShortcut();
}

Q_INVOKABLE QString BigLauncherDbusAdapterInterface::getMethod(const QString &method)
{
    QString str = method;
    return str;
}
