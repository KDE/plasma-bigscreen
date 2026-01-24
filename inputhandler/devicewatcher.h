// SPDX-FileCopyrightText: 2026 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL

#pragma once

#include <QHash>
#include <QObject>
#include <QSet>
#include <QSocketNotifier>
#include <QString>

/**
 * Uses inotify to watch input devices for open/close events.
 * When another process opens a monitored device, scans /proc to identify it.
 */
class DeviceWatcher : public QObject
{
    Q_OBJECT

public:
    explicit DeviceWatcher(QObject *parent = nullptr);
    ~DeviceWatcher() override;

    void addDevicePath(const QString &devicePath);
    void removeDevicePath(const QString &devicePath);

    bool hasOtherProcesses() const
    {
        return m_othersUsingDevice;
    }

Q_SIGNALS:
    void otherProcessesChanged(bool othersUsingDevice);

private:
    void onInotifyEvent();
    void checkDeviceAccess();
    bool isDeviceOpenByOthers() const;

    int m_inotifyFd = -1;
    QSocketNotifier *m_notifier = nullptr;
    QHash<int, QString> m_watchDescriptors; // wd -> device path
    QSet<QString> m_devicePaths;
    bool m_othersUsingDevice = false;
    qint64 m_myPid;

    static const QSet<QString> s_ignoredProcesses;
};
