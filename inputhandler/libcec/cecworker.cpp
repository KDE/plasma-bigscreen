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
    qDebug() << "CECWorker: Initializing with OSD name:" << osdName;

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

    qDebug() << "CECWorker: CEC adapter created successfully";
    m_cecAdapter->InitVideoStandalone();
    qDebug() << "CECWorker: Video standalone initialized";
    Q_EMIT initialized(true);
}

void CECWorker::discoverDevices()
{
    if (!m_cecAdapter) {
        qDebug() << "CECWorker: discoverDevices called but no adapter available";
        return;
    }

    cec_adapter_descriptor devices[10];
    int8_t count = m_cecAdapter->DetectAdapters(devices, 10, nullptr, true);
    qDebug() << "CECWorker: Detected" << count << "CEC adapter(s)";

    for (int8_t i = 0; i < count; i++) {
        qDebug() << "CECWorker: Found adapter" << i << "at" << devices[i].strComName;
        Q_EMIT deviceDiscovered(QString::fromLatin1(devices[i].strComName));
    }
}

void CECWorker::cleanup()
{
    qDebug() << "CECWorker: Starting cleanup";
    if (m_cecAdapter) {
        m_cecAdapter->Close();
        UnloadLibCec(m_cecAdapter);
        m_cecAdapter = nullptr;
    }
    qDebug() << "CECWorker: Cleanup completed";
}

void CECWorker::handleCecKeypress(void *param, const cec_keypress *key)
{
    auto *self = static_cast<CECWorker *>(param);
    qDebug() << "CECWorker: Key pressed - keycode:" << key->keycode << "duration:" << key->duration << "lastOpcode:" << self->m_lastOpcode;
    Q_EMIT self->cecKeyPressed(key->keycode, self->m_lastOpcode);
}

void CECWorker::handleCommandReceived(void *param, const cec_command *command)
{
    auto *self = static_cast<CECWorker *>(param);
    qDebug() << "CECWorker: Command received - opcode:" << command->opcode;
    self->m_lastOpcode = command->opcode;

    if (command->opcode == CEC_OPCODE_STANDBY) {
        qDebug() << "CECWorker: Standby command received";
        Q_EMIT self->cecStandbyReceived();
    }
}

void CECWorker::handleSourceActivated(void *param, const cec_logical_address, uint8_t activated)
{
    auto *self = static_cast<CECWorker *>(param);
    qDebug() << "CECWorker: Source activation changed - activated:" << (activated != 0);
    Q_EMIT self->cecSourceActivated(activated != 0);
}
