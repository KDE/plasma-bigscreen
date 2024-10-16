/***************************************************************************
 *                                                                         *
 *   SPDX-FileCopyrightText: 2021 Aditya Mehra <aix.m@outlook.com>         *
 *                                                                         *
 *   SPDX-License-Identifier: GPL-2.0-or-later                             *
 ***************************************************************************/

#ifndef TIMEDATED_INTERFACE_H
#define TIMEDATED_INTERFACE_H

#include <QObject>
#include <QVariant>
#include <QDBusAbstractInterface>
#include <QDBusConnection>
#include <QDBusPendingReply>

class OrgFreedesktopTimedate1Interface : public QDBusAbstractInterface
{
    Q_OBJECT

    Q_PROPERTY(bool CanNTP READ canNTP NOTIFY canNTPChanged)
    Q_PROPERTY(bool LocalRTC READ localRTC NOTIFY localRTCChanged)
    Q_PROPERTY(bool NTP READ nTP NOTIFY nTPChanged)
    Q_PROPERTY(bool NTPSynchronized READ nTPSynchronized NOTIFY nTPSynchronizedChanged)
    Q_PROPERTY(qulonglong RTCTimeUSec READ rTCTimeUSec NOTIFY rTCTimeUSecChanged)
    Q_PROPERTY(qulonglong TimeUSec READ timeUSec NOTIFY timeUSecChanged)
    Q_PROPERTY(QString Timezone READ timezone NOTIFY timezoneChanged)

public:
    static inline const char *staticInterfaceName()
    {
        return "org.freedesktop.timedate1";
    }

public:
    OrgFreedesktopTimedate1Interface(const QString &service, const QString &path, const QDBusConnection &connection, QObject *parent = nullptr);

    ~OrgFreedesktopTimedate1Interface();

    bool canNTP() const;
    bool localRTC() const;
    bool nTP() const;
    bool nTPSynchronized() const;
    qulonglong rTCTimeUSec() const;
    qulonglong timeUSec() const;
    QString timezone() const;

public Q_SLOTS: // METHODS
    QDBusPendingReply<> SetLocalRTC(bool in0, bool in1, bool in2);
    QDBusPendingReply<> SetNTP(bool in0, bool in1);
    QDBusPendingReply<> SetTime(qlonglong in0, bool in1, bool in2);
    QDBusPendingReply<> SetTimezone(const QString &in0, bool in1);

Q_SIGNALS: // SIGNALS
    void canNTPChanged();
    void localRTCChanged();
    void nTPChanged();
    void nTPSynchronizedChanged();
    void rTCTimeUSecChanged();
    void timeUSecChanged();
    void timezoneChanged();
};

namespace org
{
    namespace freedesktop
    {
        typedef ::OrgFreedesktopTimedate1Interface timedate1;
    }
}
#endif
