/*
 *   SPDX-FileCopyrightText: 2022 Bart Ribbers <bribbers@disroot.org>
 *
 *   SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

#include "controllermanager.h"
#include "inputhandlersettings.h"
#include "xdgremotedesktopsystem.h"

ControllerManager::ControllerManager(QObject *parent)
    : QObject(parent)
{
    auto *settings = InputHandlerSettings::self();
    m_enabled = settings->enabled();
    m_gameControllerEnabled = settings->gameControllerEnabled();
    m_cecEnabled = settings->cecEnabled();
    QStringList disabledControllers = settings->disabledControllers();
    m_disabledControllers = QSet<QString>(disabledControllers.cbegin(), disabledControllers.cend());
    QStringList startButtonDisabledWhenSuppressedControllers = settings->startButtonDisabledWhenSuppressedControllers();
    m_startButtonDisabledWhenSuppressedControllers =
        QSet<QString>(startButtonDisabledWhenSuppressedControllers.cbegin(), startButtonDisabledWhenSuppressedControllers.cend());

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

    device->setIndex(m_connectedDevices.size());

    connect(device, &Device::deviceDisconnected, this, &ControllerManager::removeDevice);

    m_connectedDevices.append(device);
    Q_EMIT connectedControllersChanged();

    // Don't send notifications for CEC devices, since we expect them to always be available
    if (device->getDeviceType() != DeviceCEC) {
        Q_EMIT deviceConnected(device);
    }
}

void ControllerManager::deviceRemoved(Device *device)
{
    qInfo() << "Device disconnected:" << device->getName();
    Q_EMIT deviceDisconnected(device);
    releasePressedInput(device);
    m_connectedDevices.removeOne(device);
    for (int i = 0; i < m_connectedDevices.size(); i++) {
        m_connectedDevices[i]->setIndex(i);
    }
    Q_EMIT connectedControllersChanged();
}

void ControllerManager::removeDevice(int deviceIndex)
{
    Device *removedDevice = m_connectedDevices.at(deviceIndex);
    m_connectedDevices.remove(deviceIndex);

    qInfo() << "Device disconnected:" << removedDevice->getName();

    Q_EMIT deviceDisconnected(removedDevice);
    releasePressedInput(removedDevice);
    delete removedDevice;

    // Reset indexes
    for (int i = 0; i < m_connectedDevices.size(); i++)
        m_connectedDevices.at(i)->setIndex(i);

    Q_EMIT connectedControllersChanged();
}

bool ControllerManager::isConnected(const QString &uniqueIdentifier) const
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

void ControllerManager::emitKey(int key, bool pressed)
{
    if (!m_inputSystem) {
        return;
    }

    if (pressed) {
        if (!m_enabled || m_pressedKeysWithoutDevice.contains(key)) {
            return;
        }
        m_pressedKeysWithoutDevice.insert(key);
    } else {
        if (!m_pressedKeysWithoutDevice.remove(key)) {
            return;
        }
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
    if (!m_inputSystem) {
        return;
    }

    if (pressed) {
        if (!m_enabled || m_pressedPointerButtonsWithoutDevice.contains(button)) {
            return;
        }
        m_pressedPointerButtonsWithoutDevice.insert(button);
    } else {
        if (!m_pressedPointerButtonsWithoutDevice.remove(button)) {
            return;
        }
    }

    m_inputSystem->emitPointerButton(button, pressed);
}

void ControllerManager::emitKey(Device *device, int key, bool pressed)
{
    if (!m_inputSystem || !device) {
        return;
    }

    QSet<int> &pressedKeys = m_pressedKeys[device];
    if (pressed) {
        if (!deviceAllowed(device) || pressedKeys.contains(key)) {
            return;
        }
        pressedKeys.insert(key);
    } else {
        if (!pressedKeys.remove(key)) {
            return;
        }
    }

    m_inputSystem->emitKey(key, pressed);
}

void ControllerManager::emitPointerMotion(Device *device, double deltaX, double deltaY)
{
    if (!deviceAllowed(device) || !m_inputSystem) {
        return;
    }

    m_inputSystem->emitPointerMotion(deltaX, deltaY);
}

void ControllerManager::emitPointerButton(Device *device, int button, bool pressed)
{
    if (!m_inputSystem || !device) {
        return;
    }

    QSet<int> &pressedButtons = m_pressedPointerButtons[device];
    if (pressed) {
        if (!deviceAllowed(device) || pressedButtons.contains(button)) {
            return;
        }
        pressedButtons.insert(button);
    } else {
        if (!pressedButtons.remove(button)) {
            return;
        }
    }

    m_inputSystem->emitPointerButton(button, pressed);
}

void ControllerManager::emitHomeAction()
{
    qDebug() << "Home action invoked";
    Q_EMIT homeActionRequested();
}

void ControllerManager::emitHomeAction(Device *device)
{
    if (!deviceAllowed(device)) {
        return;
    }

    emitHomeAction();
}

ControllerManager::~ControllerManager()
{
    releaseAllPressedInput();
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

bool ControllerManager::enabled() const
{
    return m_enabled;
}

void ControllerManager::setEnabled(bool enabled)
{
    if (m_enabled == enabled) {
        return;
    }

    if (!enabled) {
        releaseAllPressedInput();
    }

    m_enabled = enabled;
    auto *settings = InputHandlerSettings::self();
    settings->setEnabled(enabled);
    settings->save();
    Q_EMIT enabledChanged(enabled);
}

bool ControllerManager::gameControllerEnabled() const
{
    return m_gameControllerEnabled;
}

void ControllerManager::setGameControllerEnabled(bool enabled)
{
    if (m_gameControllerEnabled == enabled) {
        return;
    }

    if (!enabled) {
        releasePressedInput(DeviceGamepad);
    }

    m_gameControllerEnabled = enabled;
    auto *settings = InputHandlerSettings::self();
    settings->setGameControllerEnabled(enabled);
    settings->save();
    Q_EMIT gameControllerEnabledChanged(enabled);
    Q_EMIT connectedControllersChanged();
}

bool ControllerManager::cecEnabled() const
{
    return m_cecEnabled;
}

void ControllerManager::setCecEnabled(bool enabled)
{
    if (m_cecEnabled == enabled) {
        return;
    }

    if (!enabled) {
        releasePressedInput(DeviceCEC);
    }

    m_disabledControllers.remove(QStringLiteral("cec"));
    m_cecEnabled = enabled;
    auto *settings = InputHandlerSettings::self();
    settings->setCecEnabled(enabled);
    settings->setDisabledControllers(QStringList(m_disabledControllers.values()));
    settings->save();
    Q_EMIT cecEnabledChanged(enabled);
    Q_EMIT connectedControllersChanged();
}

bool ControllerManager::controllerEnabled(const QString &uniqueIdentifier) const
{
    if (uniqueIdentifier == QStringLiteral("cec")) {
        return m_cecEnabled;
    }

    return !m_disabledControllers.contains(uniqueIdentifier);
}

void ControllerManager::setControllerEnabled(const QString &uniqueIdentifier, bool enabled)
{
    if (uniqueIdentifier.isEmpty() || controllerEnabled(uniqueIdentifier) == enabled) {
        return;
    }

    if (uniqueIdentifier == QStringLiteral("cec")) {
        setCecEnabled(enabled);
        return;
    }

    if (enabled) {
        m_disabledControllers.remove(uniqueIdentifier);
    } else {
        releasePressedInput(deviceForUniqueIdentifier(uniqueIdentifier));
        m_disabledControllers.insert(uniqueIdentifier);
    }

    auto *settings = InputHandlerSettings::self();
    settings->setDisabledControllers(QStringList(m_disabledControllers.values()));
    settings->save();
    Q_EMIT connectedControllersChanged();
}

bool ControllerManager::startButtonEnabledWhenSuppressed(const QString &uniqueIdentifier) const
{
    return !m_startButtonDisabledWhenSuppressedControllers.contains(uniqueIdentifier);
}

void ControllerManager::setStartButtonEnabledWhenSuppressed(const QString &uniqueIdentifier, bool enabled)
{
    if (uniqueIdentifier.isEmpty() || startButtonEnabledWhenSuppressed(uniqueIdentifier) == enabled) {
        return;
    }

    if (enabled) {
        m_startButtonDisabledWhenSuppressedControllers.remove(uniqueIdentifier);
    } else {
        releasePressedInput(deviceForUniqueIdentifier(uniqueIdentifier));
        m_startButtonDisabledWhenSuppressedControllers.insert(uniqueIdentifier);
    }

    auto *settings = InputHandlerSettings::self();
    settings->setStartButtonDisabledWhenSuppressedControllers(QStringList(m_startButtonDisabledWhenSuppressedControllers.values()));
    settings->save();
    Q_EMIT connectedControllersChanged();
}

QVariantList ControllerManager::connectedControllers() const
{
    QVariantList controllers;
    for (Device *device : m_connectedDevices) {
        QVariantMap controller;
        controller.insert(QStringLiteral("name"), device->getName());
        controller.insert(QStringLiteral("uniqueIdentifier"), device->getUniqueIdentifier());
        controller.insert(QStringLiteral("iconName"), device->iconName());
        controller.insert(QStringLiteral("controllerEnabled"), controllerEnabled(device->getUniqueIdentifier()));
        controller.insert(QStringLiteral("startButtonEnabledWhenSuppressed"), startButtonEnabledWhenSuppressed(device->getUniqueIdentifier()));

        switch (device->getDeviceType()) {
        case DeviceCEC:
            controller.insert(QStringLiteral("type"), QStringLiteral("cec"));
            controller.insert(QStringLiteral("enabled"), m_cecEnabled);
            break;
        case DeviceGamepad:
            controller.insert(QStringLiteral("type"), QStringLiteral("gameController"));
            controller.insert(QStringLiteral("enabled"), m_gameControllerEnabled);
            break;
        }

        controllers.append(std::move(controller));
    }
    return controllers;
}

bool ControllerManager::deviceAllowed(Device *device) const
{
    if (!m_enabled || !device) {
        return false;
    }

    if (!controllerEnabled(device->getUniqueIdentifier())) {
        return false;
    }

    switch (device->getDeviceType()) {
    case DeviceCEC:
        return m_cecEnabled;
    case DeviceGamepad:
        return m_gameControllerEnabled;
    }

    return false;
}

Device *ControllerManager::deviceForUniqueIdentifier(const QString &uniqueIdentifier) const
{
    for (Device *device : m_connectedDevices) {
        if (device && device->getUniqueIdentifier() == uniqueIdentifier) {
            return device;
        }
    }
    return nullptr;
}

void ControllerManager::releaseAllPressedInput()
{
    if (!m_inputSystem) {
        m_pressedKeys.clear();
        m_pressedPointerButtons.clear();
        m_pressedKeysWithoutDevice.clear();
        m_pressedPointerButtonsWithoutDevice.clear();
        return;
    }

    for (auto it = m_pressedKeys.begin(); it != m_pressedKeys.end(); ++it) {
        for (int key : std::as_const(it.value())) {
            m_inputSystem->emitKey(key, false);
        }
    }
    m_pressedKeys.clear();

    for (auto it = m_pressedPointerButtons.begin(); it != m_pressedPointerButtons.end(); ++it) {
        for (int button : std::as_const(it.value())) {
            m_inputSystem->emitPointerButton(button, false);
        }
    }
    m_pressedPointerButtons.clear();

    for (int key : std::as_const(m_pressedKeysWithoutDevice)) {
        m_inputSystem->emitKey(key, false);
    }
    m_pressedKeysWithoutDevice.clear();

    for (int button : std::as_const(m_pressedPointerButtonsWithoutDevice)) {
        m_inputSystem->emitPointerButton(button, false);
    }
    m_pressedPointerButtonsWithoutDevice.clear();
}

void ControllerManager::releasePressedInput(Device *device)
{
    if (!device) {
        return;
    }

    QSet<int> pressedKeys = m_pressedKeys.take(device);
    QSet<int> pressedButtons = m_pressedPointerButtons.take(device);
    if (!m_inputSystem) {
        return;
    }

    for (int key : pressedKeys) {
        m_inputSystem->emitKey(key, false);
    }
    for (int button : pressedButtons) {
        m_inputSystem->emitPointerButton(button, false);
    }
}

void ControllerManager::releasePressedInput(DeviceType type)
{
    QVector<Device *> devices = m_connectedDevices;
    for (Device *device : devices) {
        if (device && device->getDeviceType() == type) {
            releasePressedInput(device);
        }
    }
}

#include "moc_controllermanager.cpp"
