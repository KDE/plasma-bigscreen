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

#include <sys/inotify.h>
#include <unistd.h>

const QSet<QString> DeviceWatcher::s_ignoredProcesses = {
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
    m_inotifyFd = inotify_init1(IN_NONBLOCK | IN_CLOEXEC);
    if (m_inotifyFd < 0) {
        qWarning() << "DeviceWatcher: Failed to initialize inotify";
        return;
    }

    m_notifier = new QSocketNotifier(m_inotifyFd, QSocketNotifier::Read, this);
    connect(m_notifier, &QSocketNotifier::activated, this, &DeviceWatcher::onInotifyEvent);
}

DeviceWatcher::~DeviceWatcher()
{
    if (m_inotifyFd >= 0) {
        // Remove all watches
        for (int wd : m_watchDescriptors.keys()) {
            inotify_rm_watch(m_inotifyFd, wd);
        }
        close(m_inotifyFd);
    }
}

void DeviceWatcher::addDevicePath(const QString &devicePath)
{
    if (devicePath.isEmpty() || m_devicePaths.contains(devicePath) || m_inotifyFd < 0) {
        return;
    }

    // Watch for open and close events on the device
    int wd = inotify_add_watch(m_inotifyFd, qPrintable(devicePath), IN_OPEN | IN_CLOSE_NOWRITE | IN_CLOSE_WRITE);
    if (wd < 0) {
        qWarning() << "DeviceWatcher: Failed to watch" << devicePath;
        return;
    }

    m_devicePaths.insert(devicePath);
    m_watchDescriptors.insert(wd, devicePath);

    // Initial check
    checkDeviceAccess();
}

void DeviceWatcher::removeDevicePath(const QString &devicePath)
{
    if (!m_devicePaths.remove(devicePath)) {
        return;
    }

    // Find and remove the watch descriptor
    for (auto it = m_watchDescriptors.begin(); it != m_watchDescriptors.end(); ++it) {
        if (it.value() == devicePath) {
            inotify_rm_watch(m_inotifyFd, it.key());
            m_watchDescriptors.erase(it);
            break;
        }
    }

    if (m_devicePaths.isEmpty() && m_othersUsingDevice) {
        m_othersUsingDevice = false;
        Q_EMIT otherProcessesChanged(false);
    }
}

void DeviceWatcher::onInotifyEvent()
{
    // Read and discard all pending events - we just care that something happened
    char buffer[4096];
    while (read(m_inotifyFd, buffer, sizeof(buffer)) > 0) {
        // Events consumed
    }

    // Check if device access state changed
    checkDeviceAccess();
}

void DeviceWatcher::checkDeviceAccess()
{
    bool othersFound = isDeviceOpenByOthers();

    if (othersFound != m_othersUsingDevice) {
        m_othersUsingDevice = othersFound;
        Q_EMIT otherProcessesChanged(othersFound);
    }
}

bool DeviceWatcher::isDeviceOpenByOthers() const
{
    QDir procDir(QStringLiteral("/proc"));
    const auto entries = procDir.entryList(QDir::Dirs | QDir::NoDotAndDotDot);

    for (const QString &entry : entries) {
        bool ok;
        qint64 pid = entry.toLongLong(&ok);
        if (!ok || pid == m_myPid) {
            continue;
        }

        QString fdDirPath = QStringLiteral("/proc/%1/fd").arg(pid);
        QDir fdDir(fdDirPath);
        if (!fdDir.exists()) {
            continue;
        }

        const auto fds = fdDir.entryList(QDir::NoDotAndDotDot);
        for (const QString &fd : fds) {
            QString target = QFile::symLinkTarget(fdDirPath + QLatin1Char('/') + fd);

            if (m_devicePaths.contains(target)) {
                // Check process name only when we find a match
                QFile commFile(QStringLiteral("/proc/%1/comm").arg(pid));
                if (commFile.open(QIODevice::ReadOnly)) {
                    QString name = QString::fromUtf8(commFile.readLine()).trimmed();
                    if (!s_ignoredProcesses.contains(name)) {
                        return true;
                    }
                }
                break;
            }
        }
    }

    return false;
}
