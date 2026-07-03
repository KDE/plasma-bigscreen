/*
 *   SPDX-FileCopyrightText: 2022 Bart Ribbers <bribbers@disroot.org>
 *   SPDX-FileCopyrightText: 2022 Aditya Mehra <aix.m@outlook.com>
 *   SPDX-FileCopyrightText: 2026 Devin Lin <devin@kde.org>
 *
 *   SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

#pragma once

#include <QHash>
#include <QObject>
#include <QSet>
#include <QString>
#include <QThread>
#include <QTimer>

#include <libcec/cec.h>

class CECWorker;
class Device;

class CECController : public QObject
{
    Q_OBJECT

public:
    explicit CECController(QObject *parent = nullptr);
    ~CECController() override;

    bool hasConnectedAdapters() const
    {
        return m_adapterCount > 0;
    }

    // Outbound CEC commands. Synchronous: the call blocks the caller's
    // thread until the worker thread has dispatched the request to libcec
    // and returned its result. libcec calls themselves are fast (single
    // CEC bus round-trip at most), so blocking the D-Bus caller is fine.
    // logicalAddress defaults to 0 (TV).
    bool sendStandby(int logicalAddress = 0);
    bool sendImageViewOn(int logicalAddress = 0);
    bool sendActiveSource();
    int queryDevicePowerStatus(int logicalAddress = 0);
    int queryActiveSource();
    bool isActiveSource();
    QString queryDeviceOsdName(int logicalAddress);

public Q_SLOTS:
    void requestNextKey();
    void cancelNextKeyRequest();

Q_SIGNALS:
    void enterStandby();
    void sourceActivated(bool active);
    void controllerAdded(const QString &name);
    void controllerRemoved(const QString &name);
    void nextKeyReceived(int keycode);

private Q_SLOTS:
    void onWorkerInitialized(bool success);
    void onDeviceDiscovered(const QString &comName);
    void onDeviceOpened(const QString &comName);
    void onDeviceOpenFailed(const QString &comName, const QString &error);
    void onHotplugTimeout();
    void onDeviceRemoved(const QString &udi);
    void onNextKeyTimeout();
    void onCecKeyPressed(int keycode, int duration);

private:
    QThread *m_workerThread = nullptr;
    CECWorker *m_worker = nullptr;
    QTimer m_hotplugTimer;
    QTimer m_nextKeyTimer;

    QHash<int, int> m_keyMap;
    QSet<int> m_homeActionKeys;
    QSet<QString> m_connectedDevices;
    Device *m_device = nullptr;
    int m_adapterCount = 0;
    int m_lastHandledKeycode = -1;
    bool m_initialized = false;
    bool m_catchNextInput = false;
};

Q_DECLARE_METATYPE(CEC::cec_logical_address);
