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

QT_BEGIN_NAMESPACE
class QByteArray;
template<class T>
class QList;
template<class Key, class Value>
class QMap;
class QString;
class QVariant;
QT_END_NAMESPACE

/*
 * Adaptor class for interface org.kde.biglauncher
 */
class BigLauncherDbusAdapterInterface : public QDBusAbstractAdaptor
{
    Q_OBJECT
    Q_CLASSINFO("D-Bus Interface", "org.kde.biglauncher")
    Q_CLASSINFO("D-Bus Introspection",
                ""
                "  <interface name=\"org.kde.biglauncher\">\n"
                "    <signal name=\"useColoredTilesChanged\">\n"
                "      <arg direction=\"out\" type=\"b\" name=\"msgUseColoredTiles\"/>\n"
                "    </signal>\n"
                "    <signal name=\"useExpandableTilesChanged\">\n"
                "      <arg direction=\"out\" type=\"b\" name=\"msgUseExpandableTiles\"/>\n"
                "    </signal>\n"
                "    <signal name=\"enablePmInhibitionChanged\">\n"
                "      <arg direction=\"out\" type=\"b\" name=\"msgEnablePmInhibition\"/>\n"
                "    </signal>\n"
                "    <method name=\"useColoredTiles\">\n"
                "      <arg direction=\"in\" type=\"b\" name=\"coloredTiles\"/>\n"
                "    </method>\n"
                "    <method name=\"useExpandableTiles\">\n"
                "      <arg direction=\"in\" type=\"b\" name=\"expandableTiles\"/>\n"
                "    </method>\n"
                "    <method name=\"enablePmInhibition\">\n"
                "      <arg direction=\"in\" type=\"b\" name=\"pmInhibition\"/>\n"
                "    </method>\n"
                "    <method name=\"coloredTilesActive\">\n"
                "      <arg direction=\"out\" type=\"b\"/>\n"
                "    </method>\n"
                "    <method name=\"expandableTilesActive\">\n"
                "      <arg direction=\"out\" type=\"b\"/>\n"
                "    </method>\n"
                "    <method name=\"pmInhibitionActive\">\n"
                "      <arg direction=\"out\" type=\"b\"/>\n"
                "    </method>\n"
                "    <method name=\"activateSettingsShortcut\">\n"
                "      <arg direction=\"out\" type=\"s\"/>\n"
                "    </method>\n"
                "    <method name=\"activateTasksShortcut\">\n"
                "      <arg direction=\"out\" type=\"s\"/>\n"
                "    </method>\n"
                "    <method name=\"displayHomeScreenShortcut\">\n"
                "      <arg direction=\"out\" type=\"s\"/>\n"
                "    </method>\n"
                "    <method name=\"setActivateSettingsShortcut\">\n"
                "      <arg direction=\"in\" type=\"s\" name=\"shortcut\"/>\n"
                "    </method>\n"
                "    <method name=\"setActivateTasksShortcut\">\n"
                "      <arg direction=\"in\" type=\"s\" name=\"shortcut\"/>\n"
                "    </method>\n"
                "    <method name=\"setDisplayHomeScreenShortcut\">\n"
                "      <arg direction=\"in\" type=\"s\" name=\"shortcut\"/>\n"
                "    </method>\n"
                "    <method name=\"resetActivateSettingsShortcut\">\n"
                "    </method>\n"
                "    <method name=\"resetActivateTasksShortcut\">\n"
                "    </method>\n"
                "    <method name=\"resetDisplayHomeScreenShortcut\">\n"
                "    </method>\n"
                "  </interface>\n"
                "")
public:
    BigLauncherDbusAdapterInterface(QObject *parent);
    virtual ~BigLauncherDbusAdapterInterface();
    Q_INVOKABLE QString getMethod(const QString &method);

public: // PROPERTIES
public Q_SLOTS: // METHODS
    void useColoredTiles(const bool &coloredTiles);
    void useExpandableTiles(const bool &expandableTiles);
    bool coloredTilesActive();
    bool expandableTilesActive();
    bool pmInhibitionActive();
    void enablePmInhibition(const bool &pmInhibition);

    void setColoredTilesActive(const bool &coloredTilesActive);
    void setExpandableTilesActive(const bool &expandableTilesActive);

    QString activateSettingsShortcut();
    QString activateTasksShortcut();
    QString displayHomeScreenShortcut();

    void setActivateSettingsShortcut(const QString &shortcut);
    void setActivateTasksShortcut(const QString &shortcut);
    void setDisplayHomeScreenShortcut(const QString &shortcut);

    void resetActivateSettingsShortcut();
    void resetActivateTasksShortcut();
    void resetDisplayHomeScreenShortcut();

Q_SIGNALS: // SIGNALS
    void useColoredTilesChanged(const bool &msgUseColoredTiles);
    void useExpandableTilesChanged(const bool &msgUseExpandableTiles);
    void enablePmInhibitionChanged(const bool &msgEnablePmInhibition);
    void coloredTilesActiveRequested();
    void expandableTilesActiveRequested();

private:
    bool m_useColoredTiles;
    bool m_useExpandableTiles;
    Shortcuts *m_shortcuts;
};

#endif
