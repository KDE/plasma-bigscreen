// SPDX-FileCopyrightText: 2026 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL

#pragma once

#include <QObject>
#include <QSet>
#include <QString>
#include <QStringList>
#include <QTimer>

// Watch /proc to detect when other applications have opened the same input device files.
// This is used to suppress input forwarding when games or other applications are directly
// reading from the controller.
class DeviceWatcher : public QObject
{
    Q_OBJECT

public:
    explicit DeviceWatcher(QObject *parent = nullptr);
    ~DeviceWatcher() override;

    void addDevicePath(const QString &devicePath);
    void removeDevicePath(const QString &devicePath);

    // If other processes (ex. games) are monitoring this device/controller
    bool hasOtherProcesses() const;
    QList<qint64> otherProcessPids() const;

Q_SIGNALS:
    void otherProcessesChanged(bool othersUsingDevice);

private Q_SLOTS:
    void checkDeviceAccess();

private:
    QString getProcessName(qint64 pid) const;
    bool shouldIgnoreProcess(qint64 pid, const QString &processName) const;
    QSet<qint64> findProcessesUsingDevice(const QString &devicePath) const;

    QSet<QString> m_devicePaths;
    QTimer *m_pollTimer = nullptr;
    bool m_othersUsingDevice = false;
    qint64 m_myPid;

    static constexpr int POLL_INTERVAL_MS = 2000;

    // Process names to ignore (system daemons that passively monitor input)
    static const QStringList IGNORED_PROCESSES;
};
