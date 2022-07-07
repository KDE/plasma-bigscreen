/***************************************************************************
 *                                                                         *
 *   SPDX-FileCopyrightText: 2021 Aditya Mehra <aix.m@outlook.com>         *
 *                                                                         *
 *   SPDX-License-Identifier: GPL-2.0-or-later                             *
 ***************************************************************************/

#include "timedated_interface.h"

OrgFreedesktopTimedate1Interface::OrgFreedesktopTimedate1Interface(const QString &service, const QString &path, const QDBusConnection &connection, QObject *parent)
    : QDBusAbstractInterface(service, path, staticInterfaceName(), connection, parent)
{
}

OrgFreedesktopTimedate1Interface::~OrgFreedesktopTimedate1Interface()
{
}

bool OrgFreedesktopTimedate1Interface::canNTP() const
{
    return qvariant_cast<bool>(property("CanNTP"));
}

bool OrgFreedesktopTimedate1Interface::localRTC() const
{
    return qvariant_cast<bool>(property("LocalRTC"));
}

bool OrgFreedesktopTimedate1Interface::nTP() const
{
    return qvariant_cast<bool>(property("NTP"));
}

bool OrgFreedesktopTimedate1Interface::nTPSynchronized() const
{
    return qvariant_cast<bool>(property("NTPSynchronized"));
}

qulonglong OrgFreedesktopTimedate1Interface::rTCTimeUSec() const
{
    return qvariant_cast<qulonglong>(property("RTCTimeUSec"));
}

qulonglong OrgFreedesktopTimedate1Interface::timeUSec() const
{
    return qvariant_cast<qulonglong>(property("TimeUSec"));
}

QString OrgFreedesktopTimedate1Interface::timezone() const
{
    return qvariant_cast<QString>(property("Timezone"));
}

QDBusPendingReply<> OrgFreedesktopTimedate1Interface::SetLocalRTC(bool in0, bool in1, bool in2)
{
    QList<QVariant> argumentList;
    argumentList << QVariant::fromValue(in0) << QVariant::fromValue(in1) << QVariant::fromValue(in2);
    return asyncCallWithArgumentList(QStringLiteral("SetLocalRTC"), argumentList);
}

QDBusPendingReply<> OrgFreedesktopTimedate1Interface::SetNTP(bool in0, bool in1)
{
    QList<QVariant> argumentList;
    argumentList << QVariant::fromValue(in0) << QVariant::fromValue(in1);
    return asyncCallWithArgumentList(QStringLiteral("SetNTP"), argumentList);
}

QDBusPendingReply<> OrgFreedesktopTimedate1Interface::SetTime(qlonglong in0, bool in1, bool in2)
{
    QList<QVariant> argumentList;
    argumentList << QVariant::fromValue(in0) << QVariant::fromValue(in1) << QVariant::fromValue(in2);
    return asyncCallWithArgumentList(QStringLiteral("SetTime"), argumentList);
}

QDBusPendingReply<> OrgFreedesktopTimedate1Interface::SetTimezone(const QString &in0, bool in1)
{
    QList<QVariant> argumentList;
    argumentList << QVariant::fromValue(in0) << QVariant::fromValue(in1);
    return asyncCallWithArgumentList(QStringLiteral("SetTimezone"), argumentList);
}
