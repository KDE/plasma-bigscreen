/*
 *   SPDX-FileCopyrightText: 2022 Bart Ribbers <bribbers@disroot.org>
 *
 *   SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

#include "controllermanager.h"
#include "kwinfakeinputsystem.h"
#include "xdgremotedesktopsystem.h"

#include <KConfigGroup>
#include <KLocalizedString>
#include <KSharedConfig>
#include <KWindowSystem>

class NoOpInputSystem : public AbstractSystem
{
public:
    bool init() override
    {
        return true;
    }
    void emitKey(int key, bool pressed) override
    {
        Q_UNUSED(key)
        Q_UNUSED(pressed)
    }
    void emitPointerMotion(double deltaX, double deltaY) override
    {
        Q_UNUSED(deltaX)
        Q_UNUSED(deltaY)
    }
    void emitPointerButton(int button, bool pressed) override
    {
        Q_UNUSED(button)
        Q_UNUSED(pressed)
    }
};

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
    m_inputSystem->setSupportedKeys(m_usedKeys);

    device->setIndex(m_connectedDevices.size());

    connect(device, &Device::deviceDisconnected, this, &ControllerManager::removeDevice);

    m_connectedDevices.append(device);

    // Don't send notifications for CEC devices, since we expect them to always be available
    if (device->getDeviceType() != DeviceCEC) {
        Q_EMIT deviceConnected(device);
    }
    m_lastUsed.start();
}

void ControllerManager::deviceRemoved(Device *device)
{
    qInfo() << "Device disconnected:" << device->getName();
    Q_EMIT deviceDisconnected(device);
    m_connectedDevices.removeOne(device);
    for (int i = 0; i < m_connectedDevices.size(); i++) {
        m_connectedDevices[i]->setIndex(i);
    }

    m_lastUsed.start();
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
    m_lastUsed.start();
    if (!m_enabled) {
        return;
    }

    m_inputSystem->emitKey(key, pressed);
}

void ControllerManager::emitPointerMotion(double deltaX, double deltaY)
{
    m_lastUsed.start();
    if (!m_enabled) {
        return;
    }

    m_inputSystem->emitPointerMotion(deltaX, deltaY);
}

void ControllerManager::emitPointerButton(int button, bool pressed)
{
    m_lastUsed.start();
    if (!m_enabled) {
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

void ControllerManager::noopInput()
{
    m_inputSystem.reset(new NoOpInputSystem);
}

void ControllerManager::resetInputSystem()
{
    m_inputSystem.reset();

    // Try KWin fake input first (more direct when available)
    std::unique_ptr<AbstractSystem> inputSystem(new KWinFakeInputSystem);
    if (inputSystem->init()) {
        m_inputSystem.reset(inputSystem.release());
        return;
    }

    // Fall back to XDG Remote Desktop portal
    inputSystem.reset(new XdgRemoteDesktopSystem);
    if (inputSystem->init()) {
        m_inputSystem.reset(inputSystem.release());
        return;
    }

    // No input system available
    m_inputSystem.reset(new NoOpInputSystem);
    qWarning() << "Could not find an input system, plasma-bigscreen-inputhandler will not be able to send events";
}

#include "moc_controllermanager.cpp"
