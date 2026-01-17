/*
    SPDX-FileCopyrightText: 2016 Aditya Mehra <aix.m@outlook.com>
    SPDX-License-Identifier: LGPL-2.0-or-later
*/

#ifndef BIGLAUNCHER_DBUS_H
#define BIGLAUNCHER_DBUS_H

#include "biglauncherhomescreen.h"
#include "shortcuts.h"
#include <QObject>
#include <QStringList>
#include <QDBusAbstractAdaptor>
#include <QDBusConnection>

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

    void init();
    Q_INVOKABLE QString getMethod(const QString &method);

public: // PROPERTIES
public Q_SLOTS: // METHODS
    Q_SCRIPTABLE void useColoredTiles(const bool &coloredTiles);
    Q_SCRIPTABLE bool coloredTilesActive();
    Q_SCRIPTABLE bool pmInhibitionActive();
    Q_SCRIPTABLE void enablePmInhibition(const bool &pmInhibition);

    void setColoredTilesActive(const bool &coloredTilesActive);

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
    Q_SCRIPTABLE void enablePmInhibitionChanged(const bool &msgEnablePmInhibition);
    void coloredTilesActiveRequested();
    void activateWallpaperSelectorRequested();

private:
    bool m_useColoredTiles;
    Shortcuts *m_shortcuts;

    bool m_initialized{false};
};

#endif
