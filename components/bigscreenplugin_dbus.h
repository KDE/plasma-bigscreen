/*
    SPDX-FileCopyrightText: 2016 Aditya Mehra <aix.m@outlook.com>
    SPDX-License-Identifier: LGPL-2.0-or-later
*/

#ifndef BIGSCREENPLUGIN_DBUS_H
#define BIGSCREENPLUGIN_DBUS_H

#include <QObject>
#include <QtDBus>
#include "bigscreenplugin_dbus.h"

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
 * Adaptor class for interface org.kde.bigscreen
 */
class BigscreenDbusAdapterInterface : public QDBusAbstractAdaptor
{
    Q_OBJECT
    Q_CLASSINFO("D-Bus Interface", "org.kde.bigscreen")
    Q_CLASSINFO("D-Bus Introspection",
                ""
                "  <interface name=\"org.kde.bigscreen\">\n"
                "    <method name=\"autoResolutionChanged\">\n"
                "      <arg direction=\"in\" />\n"
                "    </method>\n"
                "  </interface>\n"
                "")
public:
    BigscreenDbusAdapterInterface(QObject *parent);
    virtual ~BigscreenDbusAdapterInterface();
    Q_INVOKABLE QString getMethod(const QString &method);

public: // PROPERTIES
public Q_SLOTS: // METHODS
    void autoResolutionChanged();
Q_SIGNALS: // SIGNALS
    void autoResolutionReceivedChange();
};

#endif
