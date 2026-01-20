/*
 *   SPDX-FileCopyrightText: 2022 Bart Ribbers <bribbers@disroot.org>
 *   SPDX-FileCopyrightText: 2022 Aditya Mehra <aix.m@outlook.com>
 *
 *   SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

#pragma once

#include <QDebug>
#include <QMutex>
#include <QObject>

#include <libcec/cec.h>

class CECController : public QObject
{
    Q_OBJECT

public:
    explicit CECController();
    ~CECController() override;

    void discoverDevices();

    /** Returns true if libcec is available AND at least one adapter is detected */
    bool hasConnectedAdapters() const;

public Q_SLOTS:
    int sendNextKey();
    bool hdmiCecSupported();
    bool sendKey(uchar, CEC::cec_logical_address address = CEC::CECDEVICE_TV);
    bool powerOnDevices(CEC::cec_logical_address address = CEC::CECDEVICE_TV);
    bool powerOffDevices(CEC::cec_logical_address address = CEC::CECDEVICE_BROADCAST);
    bool makeActiveSource();
    bool setOSDName(const QString &);

Q_SIGNALS:
    void enterStandby();
    void sourceActivated(bool active);
    void keyInputCaught();
    void controllerAdded(const QString &name);
    void controllerRemoved(const QString &name);

private:
    CEC::ICECAdapter *m_cecAdapter = nullptr;
    CEC::ICECCallbacks m_cecCallbacks;
    static QHash<int, int> m_keyCodeTranslation;

    mutable QMutex m_mutex;
    bool m_initFailed = false;
    bool m_catchNextInput = false;
    int m_caughtInput = -1;
    bool m_nativeNavMode = true;
    int m_hitcommand = 0;
    int m_connectedAdapterCount = 0;

    static void handleCecKeypress(void *param, const CEC::cec_keypress *key);
    static void handleCommandReceived(void *param, const CEC::cec_command *command);
    static void handleSourceActivated(void *param, const CEC::cec_logical_address address, uint8_t activated);

    void handleCompleteEvent(const int keycode, const int keyduration, const int opcode);
};

Q_DECLARE_METATYPE(CEC::cec_logical_address);
