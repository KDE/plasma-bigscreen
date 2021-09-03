/*
    SPDX-FileCopyrightText: 2016 Aditya Mehra <aix.m@outlook.com>
    SPDX-License-Identifier: LGPL-2.0-or-later
*/

#include "bigscreenplugin_dbus.h"
#include <QByteArray>
#include <QList>
#include <QMap>
#include <QMetaObject>
#include <QString>
#include <QStringList>
#include <QVariant>
#include <QtDBus>

/*
 * Implementation of adaptor class BigscreenDbusAdapterInterface
 */

BigscreenDbusAdapterInterface::BigscreenDbusAdapterInterface(QObject *parent)
    : QDBusAbstractAdaptor(parent)
{
    // constructor
    QDBusConnection dbus = QDBusConnection::sessionBus();
    dbus.registerObject("/Plugin", this, QDBusConnection::ExportScriptableSlots | QDBusConnection::ExportNonScriptableSlots);
    dbus.registerService("org.kde.bigscreen");
    setAutoRelaySignals(true);
}

BigscreenDbusAdapterInterface::~BigscreenDbusAdapterInterface()
{
    // destructor
}

void BigscreenDbusAdapterInterface::autoResolutionChanged()
{
    emit autoResolutionReceivedChange();
}

Q_INVOKABLE QString BigscreenDbusAdapterInterface::getMethod(const QString &method)
{
    QString str = method;
    return str;
}
