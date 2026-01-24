/*
 *   SPDX-FileCopyrightText: 2022 Bart Ribbers <bribbers@disroot.org>
 *   SPDX-FileCopyrightText: 2022 Aditya Mehra <aix.m@outlook.com>
 *   SPDX-FileCopyrightText: 2026 Devin Lin <devin@kde.org>
 *
 *   SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

#pragma once

#include <QObject>
#include <libcec/cec.h>

/**
 * Worker that runs blocking libcec operations in a dedicated thread.
 */
class CECWorker : public QObject
{
    Q_OBJECT

public:
    explicit CECWorker(QObject *parent = nullptr);
    ~CECWorker() override;

public Q_SLOTS:
    void initialize(const QString &osdName);
    void discoverDevices();
    void cleanup();

Q_SIGNALS:
    void initialized(bool success);
    void deviceDiscovered(const QString &comName);

    // CEC events from callbacks
    void cecKeyPressed(int keycode, int opcode);
    void cecStandbyReceived();
    void cecSourceActivated(bool activated);

private:
    CEC::ICECAdapter *m_cecAdapter = nullptr;
    CEC::ICECCallbacks m_cecCallbacks;
    int m_lastOpcode = 0;

    static void handleCecKeypress(void *param, const CEC::cec_keypress *key);
    static void handleCommandReceived(void *param, const CEC::cec_command *command);
    static void handleSourceActivated(void *param, const CEC::cec_logical_address address, uint8_t activated);
};
