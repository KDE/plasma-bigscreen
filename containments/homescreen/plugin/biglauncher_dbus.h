/*
    SPDX-FileCopyrightText: 2016 Aditya Mehra <aix.m@outlook.com>
    SPDX-License-Identifier: LGPL-2.0-or-later
*/

#ifndef BIGLAUNCHER_DBUS_H
#define BIGLAUNCHER_DBUS_H

#include <QObject>
#include <QtDBus>
#include "biglauncherhomescreen.h"

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
                "    <signal name=\"useColoredTilesChanged\">\n"
                "      <arg direction=\"out\" type=\"b\" name=\"msgUseColoredTiles\"/>\n"
                "    </signal>\n"
                "    <signal name=\"useExpandableTilesChanged\">\n"
                "      <arg direction=\"out\" type=\"b\" name=\"msgUseExpandableTiles\"/>\n"
                "    </signal>\n"
                "    <signal name=\"enableMycroftIntegrationChanged\">\n"
                "      <arg direction=\"out\" type=\"b\" name=\"msgEnableMycroftIntegration\"/>\n"
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
                "    <method name=\"enableMycroftIntegration\">\n"
                "      <arg direction=\"in\" type=\"b\" name=\"mycroftIntegration\"/>\n"
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
                "    <method name=\"mycroftIntegrationActive\">\n"
                "      <arg direction=\"out\" type=\"b\"/>\n"
                "    </method>\n"
                "    <method name=\"pmInhibitionActive\">\n"
                "      <arg direction=\"out\" type=\"b\"/>\n"
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
    void enableMycroftIntegration(const bool &mycroftIntegration);
    bool coloredTilesActive();
    bool expandableTilesActive();
    bool mycroftIntegrationActive();
    bool pmInhibitionActive();
    void enablePmInhibition(const bool &pmInhibition);

    void setColoredTilesActive(const bool &coloredTilesActive);
    void setExpandableTilesActive(const bool &expandableTilesActive);

Q_SIGNALS: // SIGNALS
    void useColoredTilesChanged(const bool &msgUseColoredTiles);
    void useExpandableTilesChanged(const bool &msgUseExpandableTiles);
    void enableMycroftIntegrationChanged(const bool &msgEnableMycroftIntegration);
    void enablePmInhibitionChanged(const bool &msgEnablePmInhibition);
    void coloredTilesActiveRequested();
    void expandableTilesActiveRequested();
    void enableMycroftIntegrationRequested();

private:
    bool m_useColoredTiles;
    bool m_useExpandableTiles;
};

#endif
