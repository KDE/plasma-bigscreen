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
#include <libcec/cec.h>

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

    m_cecAdapter = CECInitialise(&cecConfig);

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
        QString comName = QString::fromLatin1(devices[i].strComName);
        qDebug() << "CECWorker: Found adapter" << i << "at" << comName;
        Q_EMIT deviceDiscovered(comName);

        // Actually open the adapter so we receive CEC events
        if (!m_cecAdapter->Open(devices[i].strComName)) {
            qWarning() << "CECWorker: Failed to open CEC adapter at" << comName
                       << "- check device permissions (user may need to be in 'dialout' or 'video' group)";
            Q_EMIT deviceOpenFailed(comName, QStringLiteral("Failed to open adapter - check device permissions"));
        } else {
            qDebug() << "CECWorker: Successfully opened CEC adapter at" << comName;
            Q_EMIT deviceOpened(comName);
            // Only open the first adapter
            break;
        }
    }
}

void CECWorker::closeAdapter()
{
    if (!m_cecAdapter) {
        return;
    }
    qDebug() << "CECWorker: Closing CEC adapter";
    m_cecAdapter->Close();
}

void CECWorker::cleanup()
{
    qDebug() << "CECWorker: Starting cleanup";
    if (m_cecAdapter) {
        m_cecAdapter->Close();
        CECDestroy(m_cecAdapter);
        m_cecAdapter = nullptr;
    }
    qDebug() << "CECWorker: Cleanup completed";
}

bool CECWorker::sendStandby(int logicalAddress)
{
    if (!m_cecAdapter) {
        qWarning() << "CECWorker: sendStandby called but no adapter available";
        return false;
    }
    const auto la = static_cast<cec_logical_address>(logicalAddress);
    qDebug() << "CECWorker: Sending standby to logical address" << logicalAddress;
    return m_cecAdapter->StandbyDevices(la);
}

bool CECWorker::sendImageViewOn(int logicalAddress)
{
    if (!m_cecAdapter) {
        qWarning() << "CECWorker: sendImageViewOn called but no adapter available";
        return false;
    }
    const auto la = static_cast<cec_logical_address>(logicalAddress);
    qDebug() << "CECWorker: Powering on logical address" << logicalAddress;
    return m_cecAdapter->PowerOnDevices(la);
}

bool CECWorker::sendActiveSource()
{
    if (!m_cecAdapter) {
        qWarning() << "CECWorker: sendActiveSource called but no adapter available";
        return false;
    }
    qDebug() << "CECWorker: Claiming active source as Recording Device";
    return m_cecAdapter->SetActiveSource(CEC_DEVICE_TYPE_RECORDING_DEVICE);
}

int CECWorker::queryDevicePowerStatus(int logicalAddress)
{
    if (!m_cecAdapter) {
        qWarning() << "CECWorker: queryDevicePowerStatus called but no adapter available";
        return CEC_POWER_STATUS_UNKNOWN;
    }
    const auto la = static_cast<cec_logical_address>(logicalAddress);
    return static_cast<int>(m_cecAdapter->GetDevicePowerStatus(la));
}

int CECWorker::queryActiveSource()
{
    if (!m_cecAdapter) {
        qWarning() << "CECWorker: queryActiveSource called but no adapter available";
        return CECDEVICE_UNKNOWN;
    }
    return static_cast<int>(m_cecAdapter->GetActiveSource());
}

bool CECWorker::isActiveSource()
{
    if (!m_cecAdapter) {
        qWarning() << "CECWorker: isActiveSource called but no adapter available";
        return false;
    }
    return m_cecAdapter->IsLibCECActiveSource();
}

QString CECWorker::queryDeviceOsdName(int logicalAddress)
{
    if (!m_cecAdapter) {
        qWarning() << "CECWorker: queryDeviceOsdName called but no adapter available";
        return {};
    }
    const auto la = static_cast<cec_logical_address>(logicalAddress);
    return QString::fromStdString(m_cecAdapter->GetDeviceOSDName(la));
}

// NOTE: These static callbacks are invoked from libcec's internal thread,
// NOT from the Qt worker thread.

void CECWorker::handleCecKeypress(void *param, const cec_keypress *key)
{
    auto *self = static_cast<CECWorker *>(param);
    int keycode = key->keycode;
    int duration = key->duration;
    qDebug() << "CECWorker: Key pressed - keycode:" << keycode << "duration:" << duration;
    QMetaObject::invokeMethod(self, "cecKeyPressed", Qt::QueuedConnection, Q_ARG(int, keycode), Q_ARG(int, duration));
}

void CECWorker::handleCommandReceived(void *param, const cec_command *command)
{
    auto *self = static_cast<CECWorker *>(param);
    qDebug() << "CECWorker: Command received - opcode:" << command->opcode;

    if (command->opcode == CEC_OPCODE_STANDBY) {
        qDebug() << "CECWorker: Standby command received";
        QMetaObject::invokeMethod(self, "cecStandbyReceived", Qt::QueuedConnection);
    }
}

void CECWorker::handleSourceActivated(void *param, const cec_logical_address, uint8_t activated)
{
    auto *self = static_cast<CECWorker *>(param);
    bool isActivated = activated != 0;
    qDebug() << "CECWorker: Source activation changed - activated:" << isActivated;
    QMetaObject::invokeMethod(self, "cecSourceActivated", Qt::QueuedConnection, Q_ARG(bool, isActivated));
}
