/*
    SPDX-FileCopyrightText: 2016 Aditya Mehra <aix.m@outlook.com>
    SPDX-License-Identifier: LGPL-2.0-or-later
*/

#pragma once

#include "shortcuts.h"
#include <KConfigGroup>
#include <QDBusAbstractAdaptor>
#include <QDBusConnection>
#include <QObject>
#include <QStringList>

/*
 * Adaptor class for interface org.kde.biglauncher
 */
class BigLauncherDbusAdapterInterface : public QObject
{
    Q_OBJECT
    Q_CLASSINFO("D-Bus Interface", "org.kde.biglauncher")

public:
    BigLauncherDbusAdapterInterface(QObject *parent = nullptr);
    virtual ~BigLauncherDbusAdapterInterface();

    static BigLauncherDbusAdapterInterface *instance();

    void init(const KConfigGroup &config);
    Q_INVOKABLE QString getMethod(const QString &method);

public: // PROPERTIES
public Q_SLOTS: // METHODS
    Q_SCRIPTABLE void useColoredTiles(const bool &coloredTiles);
    Q_SCRIPTABLE bool coloredTilesActive();

    Q_SCRIPTABLE void useWallpaperBlur(const bool &wallpaperBlur);
    Q_SCRIPTABLE bool wallpaperBlurActive();

    Q_SCRIPTABLE void activateWallpaperSelector();
    Q_SCRIPTABLE QString activateSettingsShortcut();
    Q_SCRIPTABLE QString activateTasksShortcut();
    Q_SCRIPTABLE QString displayHomeScreenShortcut();

    Q_SCRIPTABLE void setActivateSettingsShortcut(const QString &shortcut);
    Q_SCRIPTABLE void setActivateTasksShortcut(const QString &shortcut);
    Q_SCRIPTABLE void setDisplayHomeScreenShortcut(const QString &shortcut);

    Q_SCRIPTABLE void resetActivateSettingsShortcut();
    Q_SCRIPTABLE void resetActivateTasksShortcut();
    Q_SCRIPTABLE void resetDisplayHomeScreenShortcut();

Q_SIGNALS: // SIGNALS
    Q_SCRIPTABLE void useColoredTilesChanged(const bool &msgUseColoredTiles);
    Q_SCRIPTABLE void useWallpaperBlurChanged(const bool &msgUseWallpaperBlur);
    void activateWallpaperSelectorRequested();

private:
    KConfigGroup m_config;
    Shortcuts *m_shortcuts;

    bool m_initialized{false};
};
