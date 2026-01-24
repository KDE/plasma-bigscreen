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
#include <QThread>
#include <QTimer>

#include <libcec/cec.h>

class CECWorker;

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
    void onHotplugTimeout();
    void onNextKeyTimeout();
    void onCecKeyPressed(int keycode, int opcode);

private:
    QThread *m_workerThread = nullptr;
    CECWorker *m_worker = nullptr;
    QTimer m_hotplugTimer;
    QTimer m_nextKeyTimer;

    static QHash<int, int> s_keyMap;
    QSet<QString> m_connectedDevices;
    int m_adapterCount = 0;
    bool m_initialized = false;
    bool m_catchNextInput = false;
};

Q_DECLARE_METATYPE(CEC::cec_logical_address);
