/*
    SPDX-FileCopyrightText: 2016 Aditya Mehra <aix.m@outlook.com>
    SPDX-License-Identifier: LGPL-2.0-or-later
*/

#include "biglauncher_dbus.h"
#include "biglauncheradaptor.h"
#include "configuration.h"
#include <QByteArray>
#include <QDBusMessage>
#include <QList>
#include <QMap>
#include <QMetaObject>
#include <QString>
#include <QVariant>

/*
 * Implementation of adaptor class BigLauncherDbusAdapterInterface
 */

BigLauncherDbusAdapterInterface *BigLauncherDbusAdapterInterface::instance()
{
    static BigLauncherDbusAdapterInterface *s_self = nullptr;
    if (!s_self) {
        s_self = new BigLauncherDbusAdapterInterface;
    }
    return s_self;
}

BigLauncherDbusAdapterInterface::BigLauncherDbusAdapterInterface(QObject *parent)
    : QObject(parent)
    , m_shortcuts{Shortcuts::instance()}
{
}

BigLauncherDbusAdapterInterface::~BigLauncherDbusAdapterInterface()
{
}

void BigLauncherDbusAdapterInterface::init()
{
    if (!m_initialized) {
        new BiglauncherAdaptor{this};

        QDBusConnection dbus = QDBusConnection::sessionBus();
        dbus.registerObject(QStringLiteral("/BigLauncher"), this);
        dbus.registerService("org.kde.biglauncher");
        // setAutoRelaySignals(true);

        m_initialized = true;
    }
}

void BigLauncherDbusAdapterInterface::useColoredTiles(const bool &coloredTiles)
{
    Q_EMIT useColoredTilesChanged(coloredTiles);
}

void BigLauncherDbusAdapterInterface::enablePmInhibition(const bool &pmInhibition)
{
    Configuration::self().setPmInhibitionEnabled(pmInhibition);
    Q_EMIT enablePmInhibitionChanged(pmInhibition);
}

bool BigLauncherDbusAdapterInterface::coloredTilesActive()
{
    return m_useColoredTiles;
}

bool BigLauncherDbusAdapterInterface::pmInhibitionActive()
{
    return Configuration::self().pmInhibitionEnabled();
}

void BigLauncherDbusAdapterInterface::setColoredTilesActive(const bool &coloredTilesActive)
{
    m_useColoredTiles = coloredTilesActive;
}

void BigLauncherDbusAdapterInterface::useWallpaperBlur(const bool &wallpaperBlur)
{
    Q_EMIT useWallpaperBlurChanged(wallpaperBlur);
}

bool BigLauncherDbusAdapterInterface::wallpaperBlurActive()
{
    return m_useWallpaperBlur;
}

void BigLauncherDbusAdapterInterface::setWallpaperBlurActive(const bool &wallpaperBlurActive)
{
    m_useWallpaperBlur = wallpaperBlurActive;
}

void BigLauncherDbusAdapterInterface::activateWallpaperSelector()
{
    Q_EMIT activateWallpaperSelectorRequested();
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
