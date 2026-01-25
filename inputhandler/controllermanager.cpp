/*
 *   SPDX-FileCopyrightText: 2022 Bart Ribbers <bribbers@disroot.org>
 *
 *   SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

#include "controllermanager.h"
#include "xdgremotedesktopsystem.h"

#include <KConfigGroup>
#include <KLocalizedString>
#include <KSharedConfig>
#include <KWindowSystem>

ControllerManager::ControllerManager(QObject *parent)
    : QObject(parent)
{
    resetInputSystem();
}

ControllerManager &ControllerManager::instance()
{
    static ControllerManager _instance;
    return _instance;
}

void ControllerManager::newDevice(Device *device)
{
    qInfo() << "New device connected:" << device->getName();

    m_usedKeys += device->usedKeys();

    device->setIndex(m_connectedDevices.size());

    connect(device, &Device::deviceDisconnected, this, &ControllerManager::removeDevice);

    m_connectedDevices.append(device);

    // Don't send notifications for CEC devices, since we expect them to always be available
    if (device->getDeviceType() != DeviceCEC) {
        Q_EMIT deviceConnected(device);
    }
}

void ControllerManager::deviceRemoved(Device *device)
{
    qInfo() << "Device disconnected:" << device->getName();
    Q_EMIT deviceDisconnected(device);
    m_connectedDevices.removeOne(device);
    for (int i = 0; i < m_connectedDevices.size(); i++) {
        m_connectedDevices[i]->setIndex(i);
    }
}

void ControllerManager::removeDevice(int deviceIndex)
{
    Device *removedDevice = m_connectedDevices.at(deviceIndex);
    m_connectedDevices.remove(deviceIndex);

    qInfo() << "Device disconnected:" << removedDevice->getName();

    Q_EMIT deviceDisconnected(removedDevice);
    delete removedDevice;

    // Reset indexes
    for (int i = 0; i < m_connectedDevices.size(); i++)
        m_connectedDevices.at(i)->setIndex(i);
}

bool ControllerManager::isConnected(QString uniqueIdentifier)
{
    if (m_connectedDevices.size() < 1)
        return false;

    return std::find_if(m_connectedDevices.begin(),
                        m_connectedDevices.end(),
                        [&uniqueIdentifier](Device *other) {
                            return other->getUniqueIdentifier() == uniqueIdentifier;
                        })
        != m_connectedDevices.end();
}

QVector<Device *> ControllerManager::connectedDevices()
{
    return m_connectedDevices;
}

void ControllerManager::emitKey(int key, bool pressed)
{
    if (!m_enabled || !m_inputSystem) {
        return;
    }

    m_inputSystem->emitKey(key, pressed);
}

void ControllerManager::emitPointerMotion(double deltaX, double deltaY)
{
    if (!m_enabled || !m_inputSystem) {
        return;
    }

    m_inputSystem->emitPointerMotion(deltaX, deltaY);
}

void ControllerManager::emitPointerButton(int button, bool pressed)
{
    if (!m_enabled || !m_inputSystem) {
        return;
    }

    m_inputSystem->emitPointerButton(button, pressed);
}

void ControllerManager::emitHomeAction()
{
    qDebug() << "Home action invoked";
    Q_EMIT homeActionRequested();
}

ControllerManager::~ControllerManager()
{
    m_connectedDevices.clear();
}

void ControllerManager::resetInputSystem()
{
    m_inputSystem.reset();

    std::unique_ptr<XdgRemoteDesktopSystem> inputSystem(new XdgRemoteDesktopSystem);
    if (inputSystem->init()) {
        m_inputSystem.reset(inputSystem.release());
        return;
    }

    // No input system available
    m_inputSystem.reset();
    qWarning() << "Could not setup input system, plasma-bigscreen-inputhandler will not be able to send events";
}

#include "moc_controllermanager.cpp"
