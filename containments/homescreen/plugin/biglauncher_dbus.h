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

#ifndef BIGLAUNCHER_DBUS_H
#define BIGLAUNCHER_DBUS_H

#include <QObject>
#include <QtDBus>
QT_BEGIN_NAMESPACE
class QByteArray;
template<class T>
class QList;
template<class Key, class Value>
class QMap;
class QString;
class QStringList;
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
                "    <signal name=\"sendShowMycroft\">\n"
                "      <arg direction=\"out\" type=\"s\" name=\"msgShowMycroft\"/>\n"
                "    </signal>\n"
                "    <signal name=\"sendShowSkills\">\n"
                "      <arg direction=\"out\" type=\"s\" name=\"msgShowSkills\"/>\n"
                "    </signal>\n"
                "    <signal name=\"installList\">\n"
                "      <arg direction=\"out\" type=\"s\" name=\"msgShowInstallSkills\"/>\n"
                "    </signal>\n"
                "    <signal name=\"recipeMethod\">\n"
                "      <arg direction=\"out\" type=\"s\" name=\"msgRecipeMethod\"/>\n"
                "    </signal>\n"
                "    <signal name=\"kioMethod\">\n"
                "      <arg direction=\"out\" type=\"s\" name=\"msgKioMethod\"/>\n"
                "    </signal>\n"
                "    <method name=\"showMycroft\"/>\n"
                "    <method name=\"showSkills\"/>\n"
                "    <method name=\"showSkillsInstaller\"/>\n"
                "    <method name=\"showRecipeMethod\">\n"
                "      <arg direction=\"in\" type=\"s\" name=\"recipeName\"/>\n"
                "     </method>\n"
                "    <method name=\"sendKioMethod\">\n"
                "      <arg direction=\"in\" type=\"s\" name=\"kioString\"/>\n"
                "     </method>\n"
                "  </interface>\n"
                "")
public:
    BigLauncherDbusAdapterInterface(QObject *parent);
    virtual ~BigLauncherDbusAdapterInterface();
    Q_INVOKABLE QString getMethod(const QString &method);

public: // PROPERTIES
public Q_SLOTS: // METHODS
    void showMycroft();
    void showSkills();
    void showSkillsInstaller();
    void showRecipeMethod(const QString &recipeName);
    void sendKioMethod(const QString &kioString);
Q_SIGNALS: // SIGNALS
    void sendShowMycroft(const QString &msgShowMycroft);
    void sendShowSkills(const QString &msgShowSkills);
    void installList(const QString &msgShowInstallSkills);
    void recipeMethod(const QString &msgRecipeMethod);
    void kioMethod(const QString &msgKioMethod);
};

#endif
