/*
 *   SPDX-FileCopyrightText: 2026 Devin Lin <devin@kde.org>
 *
 *   SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

#include "devicewatcher.h"

#include <QCoreApplication>
#include <QDebug>
#include <QDir>
#include <QFile>
#include <QFileInfo>

// System daemons that commonly have input devices open but aren't actually
// consuming gamepad input. These should be ignored when detecting "other" processes.
const QStringList DeviceWatcher::IGNORED_PROCESSES = {
    QStringLiteral("systemd-logind"),
    QStringLiteral("udevd"),
    QStringLiteral("systemd-udevd"),
    QStringLiteral("upowerd"),
    QStringLiteral("acpid"),
    QStringLiteral("thermald"),
    QStringLiteral("irqbalance"),
    QStringLiteral("inputattach"),
    QStringLiteral("joystickwake"),
};

DeviceWatcher::DeviceWatcher(QObject *parent)
    : QObject(parent)
    , m_myPid(QCoreApplication::applicationPid())
{
    m_pollTimer = new QTimer(this);
    connect(m_pollTimer, &QTimer::timeout, this, &DeviceWatcher::checkDeviceAccess);
}

DeviceWatcher::~DeviceWatcher()
{
    if (m_pollTimer) {
        m_pollTimer->stop();
    }
}

void DeviceWatcher::addDevicePath(const QString &devicePath)
{
    if (devicePath.isEmpty()) {
        return;
    }

    m_devicePaths.insert(devicePath);
    qDebug() << "DeviceWatcher: Now monitoring" << devicePath;

    // Start polling if we have devices to watch
    if (!m_pollTimer->isActive() && !m_devicePaths.isEmpty()) {
        m_pollTimer->start(POLL_INTERVAL_MS);
        // Do an immediate check
        checkDeviceAccess();
    }
}

void DeviceWatcher::removeDevicePath(const QString &devicePath)
{
    m_devicePaths.remove(devicePath);
    qDebug() << "DeviceWatcher: Stopped monitoring" << devicePath;

    // Stop polling if no devices left
    if (m_devicePaths.isEmpty()) {
        m_pollTimer->stop();
        if (m_othersUsingDevice) {
            m_othersUsingDevice = false;
            Q_EMIT otherProcessesChanged(false);
        }
    }
}

bool DeviceWatcher::hasOtherProcesses() const
{
    return m_othersUsingDevice;
}

QList<qint64> DeviceWatcher::otherProcessPids() const
{
    QSet<qint64> allPids;
    for (const QString &devicePath : m_devicePaths) {
        allPids.unite(findProcessesUsingDevice(devicePath));
    }
    return allPids.values();
}

void DeviceWatcher::checkDeviceAccess()
{
    bool othersFound = false;

    for (const QString &devicePath : m_devicePaths) {
        QSet<qint64> pids = findProcessesUsingDevice(devicePath);
        if (!pids.isEmpty()) {
            othersFound = true;
            break;
        }
    }

    if (othersFound != m_othersUsingDevice) {
        m_othersUsingDevice = othersFound;
        qInfo() << "DeviceWatcher: Other processes using device:" << othersFound;
        Q_EMIT otherProcessesChanged(othersFound);
    }
}

QString DeviceWatcher::getProcessName(qint64 pid) const
{
    QFile commFile(QStringLiteral("/proc/%1/comm").arg(pid));
    if (commFile.open(QIODevice::ReadOnly | QIODevice::Text)) {
        return QString::fromUtf8(commFile.readLine()).trimmed();
    }
    return QString();
}

bool DeviceWatcher::shouldIgnoreProcess(qint64 pid, const QString &processName) const
{
    // Always ignore ourselves
    if (pid == m_myPid) {
        return true;
    }

    // Check against the list of known system processes
    for (const QString &ignored : IGNORED_PROCESSES) {
        if (processName == ignored) {
            return true;
        }
    }

    return false;
}

QSet<qint64> DeviceWatcher::findProcessesUsingDevice(const QString &devicePath) const
{
    QSet<qint64> pids;

    // Resolve the device path to handle symlinks
    QFileInfo deviceInfo(devicePath);
    QString resolvedPath = deviceInfo.canonicalFilePath();
    if (resolvedPath.isEmpty()) {
        resolvedPath = devicePath;
    }

    QDir procDir(QStringLiteral("/proc"));
    const QStringList entries = procDir.entryList(QDir::Dirs | QDir::NoDotAndDotDot);

    for (const QString &entry : entries) {
        bool ok;
        qint64 pid = entry.toLongLong(&ok);
        if (!ok) {
            continue;
        }

        // Check this process's file descriptors
        QDir fdDir(QStringLiteral("/proc/%1/fd").arg(pid));
        if (!fdDir.exists()) {
            continue;
        }

        const QStringList fds = fdDir.entryList(QDir::NoDotAndDotDot);
        for (const QString &fd : fds) {
            QString fdPath = fdDir.absoluteFilePath(fd);
            QFileInfo fdInfo(fdPath);

            // readlink on the fd symlink
            QString target = fdInfo.symLinkTarget();
            if (target == resolvedPath || target == devicePath) {
                // Found a process with this device open
                QString processName = getProcessName(pid);
                if (!shouldIgnoreProcess(pid, processName)) {
                    qDebug() << "DeviceWatcher: Process" << pid << processName << "has" << devicePath << "open";
                    pids.insert(pid);
                }
                break; // No need to check more fds for this process
            }
        }
    }

    return pids;
}
