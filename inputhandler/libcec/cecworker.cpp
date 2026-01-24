/*
 *   SPDX-FileCopyrightText: 2022 Bart Ribbers <bribbers@disroot.org>
 *   SPDX-FileCopyrightText: 2022 Aditya Mehra <aix.m@outlook.com>
 *   SPDX-FileCopyrightText: 2026 Devin Lin <devin@kde.org>
 *
 *   SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

#include "cecworker.h"

#include <QDebug>

#include <iostream>
#include <libcec/cecloader.h>
#include <libcec/cectypes.h>

using namespace CEC;

CECWorker::CECWorker(QObject *parent)
    : QObject(parent)
{
    m_cecCallbacks.Clear();
    m_cecCallbacks.keyPress = &CECWorker::handleCecKeypress;
    m_cecCallbacks.commandReceived = &CECWorker::handleCommandReceived;
    m_cecCallbacks.sourceActivated = &CECWorker::handleSourceActivated;
}

CECWorker::~CECWorker()
{
    cleanup();
}

void CECWorker::initialize(const QString &osdName)
{
    libcec_configuration cecConfig;
    cecConfig.Clear();
    cecConfig.bActivateSource = 0;
    snprintf(cecConfig.strDeviceName, LIBCEC_OSD_NAME_SIZE, "%s", qPrintable(osdName));
    cecConfig.clientVersion = LIBCEC_VERSION_CURRENT;
    cecConfig.deviceTypes.Add(CEC_DEVICE_TYPE_RECORDING_DEVICE);
    cecConfig.callbacks = &m_cecCallbacks;
    cecConfig.callbackParam = this;

    m_cecAdapter = LibCecInitialise(&cecConfig);

    if (!m_cecAdapter) {
        qCritical() << "Could not create CEC adapter";
        Q_EMIT initialized(false);
        return;
    }

    m_cecAdapter->InitVideoStandalone();
    Q_EMIT initialized(true);
}

void CECWorker::discoverDevices()
{
    if (!m_cecAdapter) {
        return;
    }

    cec_adapter_descriptor devices[10];
    int8_t count = m_cecAdapter->DetectAdapters(devices, 10, nullptr, true);

    for (int8_t i = 0; i < count; i++) {
        Q_EMIT deviceDiscovered(QString::fromLatin1(devices[i].strComName));
    }
}

void CECWorker::cleanup()
{
    if (m_cecAdapter) {
        m_cecAdapter->Close();
        UnloadLibCec(m_cecAdapter);
        m_cecAdapter = nullptr;
    }
}

void CECWorker::handleCecKeypress(void *param, const cec_keypress *key)
{
    auto *self = static_cast<CECWorker *>(param);
    Q_EMIT self->cecKeyPressed(key->keycode, self->m_lastOpcode);
}

void CECWorker::handleCommandReceived(void *param, const cec_command *command)
{
    auto *self = static_cast<CECWorker *>(param);
    self->m_lastOpcode = command->opcode;

    if (command->opcode == CEC_OPCODE_STANDBY) {
        Q_EMIT self->cecStandbyReceived();
    }
}

void CECWorker::handleSourceActivated(void *param, const cec_logical_address, uint8_t activated)
{
    auto *self = static_cast<CECWorker *>(param);
    Q_EMIT self->cecSourceActivated(activated != 0);
}
