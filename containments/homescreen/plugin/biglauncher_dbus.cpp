/*
    SPDX-FileCopyrightText: 2016 Aditya Mehra <aix.m@outlook.com>
    SPDX-License-Identifier: LGPL-2.0-or-later
*/

#include "biglauncher_dbus.h"
#include "biglauncheradaptor.h"
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

void BigLauncherDbusAdapterInterface::init(const KConfigGroup &config)
{
    if (!m_initialized) {
        m_config = config;

        new BiglauncherAdaptor{this};

        QDBusConnection dbus = QDBusConnection::sessionBus();
        dbus.registerObject(QStringLiteral("/BigLauncher"), this);
        dbus.registerService("org.kde.biglauncher");

        m_initialized = true;
    }
}

void BigLauncherDbusAdapterInterface::useColoredTiles(const bool &coloredTiles)
{
    m_config.writeEntry("coloredTiles", coloredTiles);
    m_config.sync();
    Q_EMIT useColoredTilesChanged(coloredTiles);
}

bool BigLauncherDbusAdapterInterface::coloredTilesActive()
{
    return m_config.readEntry("coloredTiles", true);
}

void BigLauncherDbusAdapterInterface::useWallpaperBlur(const bool &wallpaperBlur)
{
    m_config.writeEntry("wallpaperBlur", wallpaperBlur);
    m_config.sync();
    Q_EMIT useWallpaperBlurChanged(wallpaperBlur);
}

bool BigLauncherDbusAdapterInterface::wallpaperBlurActive()
{
    return m_config.readEntry("wallpaperBlur", false);
}

void BigLauncherDbusAdapterInterface::activateWallpaperSelector()
{
    Q_EMIT activateWallpaperSelectorRequested();
}

QString BigLauncherDbusAdapterInterface::activateSettingsShortcut()
{
    QStringList qs;
    for (const QKeySequence &seq : m_shortcuts->activateSettingsShortcut()) {
        qs += seq.toString();
    }
    return qs.join(", ");
}

QString BigLauncherDbusAdapterInterface::activateTasksShortcut()
{
    QStringList qs;
    for (const QKeySequence &seq : m_shortcuts->activateTasksShortcut()) {
        qs += seq.toString();
    }
    return qs.join(", ");
}

QString BigLauncherDbusAdapterInterface::displayHomeScreenShortcut()
{
    QStringList qs;
    for (const QKeySequence &seq : m_shortcuts->displayHomeScreenShortcut()) {
        qs += seq.toString();
    }
    return qs.join(", ");
}

QString BigLauncherDbusAdapterInterface::displayHomeOverlayShortcut()
{
    QStringList qs;
    for (const QKeySequence &seq : m_shortcuts->displayHomeOverlayShortcut()) {
        qs += seq.toString();
    }
    return qs.join(", ");
}

bool BigLauncherDbusAdapterInterface::setActivateSettingsShortcut(const QString &shortcut)
{
    QKeySequence seq = QKeySequence::fromString(shortcut);
    return m_shortcuts->setActivateSettingsShortcut(seq);
}

bool BigLauncherDbusAdapterInterface::setActivateTasksShortcut(const QString &shortcut)
{
    QKeySequence seq = QKeySequence::fromString(shortcut);
    return m_shortcuts->setActivateTasksShortcut(seq);
}

bool BigLauncherDbusAdapterInterface::setDisplayHomeScreenShortcut(const QString &shortcut)
{
    QKeySequence seq = QKeySequence::fromString(shortcut);
    return m_shortcuts->setDisplayHomeScreenShortcut(seq);
}

bool BigLauncherDbusAdapterInterface::setDisplayHomeOverlayShortcut(const QString &shortcut)
{
    QKeySequence seq = QKeySequence::fromString(shortcut);
    return m_shortcuts->setDisplayHomeOverlayShortcut(seq);
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

void BigLauncherDbusAdapterInterface::resetDisplayHomeOverlayShortcut()
{
    m_shortcuts->resetDisplayHomeOverlayShortcut();
}

Q_INVOKABLE QString BigLauncherDbusAdapterInterface::getMethod(const QString &method)
{
    QString str = method;
    return str;
}
