/*
 *   SPDX-FileCopyrightText: 2026 Devin Lin <devin@kde.org>
 *
 *   SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

#include "inputhandlerdbus.h"
#include "controllermanager.h"
#include "inputhandleradaptor.h"
#include "sdlcontroller.h"

#ifdef HAS_LIBCEC
#include "libcec/ceccontroller.h"
#include <libcec/cectypes.h>
#endif

#include <QDBusConnection>
#include <QDBusError>
#include <QDebug>

InputHandlerDBus::InputHandlerDBus(QObject *parent)
    : QObject(parent)
{
    new InputhandlerAdaptor(this);

    QDBusConnection sessionBus = QDBusConnection::sessionBus();

    if (!sessionBus.registerService(QStringLiteral("org.kde.plasma.bigscreen.inputhandler"))) {
        qWarning() << "Failed to register DBus service org.kde.plasma.bigscreen.inputhandler:" << sessionBus.lastError().message();
    }

    if (!sessionBus.registerObject(QStringLiteral("/InputHandler"), this)) {
        qWarning() << "Failed to register DBus object /InputHandler:" << sessionBus.lastError().message();
    }

    connect(&ControllerManager::instance(), &ControllerManager::homeActionRequested, this, &InputHandlerDBus::homeActionRequested);
    connect(&ControllerManager::instance(), &ControllerManager::enabledChanged, this, &InputHandlerDBus::enabledChanged);
    connect(&ControllerManager::instance(), &ControllerManager::gameControllerEnabledChanged, this, &InputHandlerDBus::gameControllerEnabledChanged);
    connect(&ControllerManager::instance(), &ControllerManager::cecEnabledChanged, this, &InputHandlerDBus::cecEnabledChanged);
    connect(&ControllerManager::instance(), &ControllerManager::connectedControllersChanged, this, &InputHandlerDBus::connectedControllersChanged);

    qInfo() << "InputHandlerDBus registered on session bus";
}

InputHandlerDBus::~InputHandlerDBus()
{
    QDBusConnection sessionBus = QDBusConnection::sessionBus();
    sessionBus.unregisterObject(QStringLiteral("/InputHandler"));
    sessionBus.unregisterService(QStringLiteral("org.kde.plasma.bigscreen.inputhandler"));
}

void InputHandlerDBus::setSdlController(SdlController *controller)
{
    m_sdlController = controller;

    if (m_sdlController) {
        connect(m_sdlController, &SdlController::controllerAdded, this, &InputHandlerDBus::sdlControllerAdded);
        connect(m_sdlController, &SdlController::controllerRemoved, this, &InputHandlerDBus::sdlControllerRemoved);
        connect(m_sdlController, &SdlController::isSuppressInputChanged, this, &InputHandlerDBus::inputSuppressedChanged);
        connect(m_sdlController, &SdlController::autoSuppressInputChanged, this, &InputHandlerDBus::autoSuppressInputChanged);
    }
}

#ifdef HAS_LIBCEC
void InputHandlerDBus::setCecController(CECController *controller)
{
    m_cecController = controller;

    if (m_cecController) {
        connect(m_cecController, &CECController::controllerAdded, this, &InputHandlerDBus::cecControllerAdded);
        connect(m_cecController, &CECController::controllerRemoved, this, &InputHandlerDBus::cecControllerRemoved);
    }
}
#endif

bool InputHandlerDBus::isSdlControllerConnected() const
{
    if (!m_sdlController) {
        return false;
    }
    return m_sdlController->hasConnectedControllers();
}

bool InputHandlerDBus::isCecControllerConnected() const
{
#ifdef HAS_LIBCEC
    if (!m_cecController) {
        return false;
    }
    return m_cecController->hasConnectedAdapters();
#else
    return false;
#endif
}

bool InputHandlerDBus::isInputSuppressed() const
{
    if (!m_sdlController) {
        return false;
    }
    return m_sdlController->isSuppressInput();
}

bool InputHandlerDBus::isInputManuallySuppressed() const
{
    if (!m_sdlController) {
        return false;
    }
    return m_sdlController->isManualSuppressInput();
}

bool InputHandlerDBus::autoSuppressInput() const
{
    if (!m_sdlController) {
        return true;
    }
    return m_sdlController->autoSuppressInput();
}

void InputHandlerDBus::setAutoSuppressInput(bool enabled)
{
    if (!m_sdlController) {
        return;
    }
    m_sdlController->setAutoSuppressInput(enabled);
}

bool InputHandlerDBus::isEnabled() const
{
    return ControllerManager::instance().enabled();
}

void InputHandlerDBus::setEnabled(bool enabled)
{
    ControllerManager::instance().setEnabled(enabled);
}

bool InputHandlerDBus::isGameControllerEnabled() const
{
    return ControllerManager::instance().gameControllerEnabled();
}

void InputHandlerDBus::setGameControllerEnabled(bool enabled)
{
    ControllerManager::instance().setGameControllerEnabled(enabled);
}

bool InputHandlerDBus::isCecEnabled() const
{
    return ControllerManager::instance().cecEnabled();
}

void InputHandlerDBus::setCecEnabled(bool enabled)
{
    ControllerManager::instance().setCecEnabled(enabled);
}

QVariantList InputHandlerDBus::connectedControllers() const
{
    return ControllerManager::instance().connectedControllers();
}

void InputHandlerDBus::setControllerEnabled(const QString &uniqueIdentifier, bool enabled)
{
    ControllerManager::instance().setControllerEnabled(uniqueIdentifier, enabled);
}

void InputHandlerDBus::setStartButtonEnabledWhenSuppressed(const QString &uniqueIdentifier, bool enabled)
{
    ControllerManager::instance().setStartButtonEnabledWhenSuppressed(uniqueIdentifier, enabled);
}

void InputHandlerDBus::setInputSuppressed(bool suppress)
{
    if (!m_sdlController) {
        return;
    }
    m_sdlController->setSuppressInput(suppress);
}

bool InputHandlerDBus::sendStandby(int logicalAddress)
{
#ifdef HAS_LIBCEC
    if (!m_cecController) {
        return false;
    }
    return m_cecController->sendStandby(logicalAddress);
#else
    Q_UNUSED(logicalAddress);
    return false;
#endif
}

bool InputHandlerDBus::sendImageViewOn(int logicalAddress)
{
#ifdef HAS_LIBCEC
    if (!m_cecController) {
        return false;
    }
    return m_cecController->sendImageViewOn(logicalAddress);
#else
    Q_UNUSED(logicalAddress);
    return false;
#endif
}

bool InputHandlerDBus::sendActiveSource()
{
#ifdef HAS_LIBCEC
    if (!m_cecController) {
        return false;
    }
    return m_cecController->sendActiveSource();
#else
    return false;
#endif
}

int InputHandlerDBus::queryDevicePowerStatus(int logicalAddress)
{
#ifdef HAS_LIBCEC
    if (!m_cecController) {
        return CEC::CEC_POWER_STATUS_UNKNOWN;
    }
    return m_cecController->queryDevicePowerStatus(logicalAddress);
#else
    Q_UNUSED(logicalAddress);
    // libcec's CEC_POWER_STATUS_UNKNOWN, hard-coded so we don't need
    // the libcec headers in non-libcec builds.
    return 0x99;
#endif
}

int InputHandlerDBus::queryActiveSource()
{
#ifdef HAS_LIBCEC
    if (!m_cecController) {
        return CEC::CECDEVICE_UNKNOWN;
    }
    return m_cecController->queryActiveSource();
#else
    // libcec's CECDEVICE_UNKNOWN, hard-coded so we don't need
    // the libcec headers in non-libcec builds.
    return -1;
#endif
}

bool InputHandlerDBus::isActiveSource()
{
#ifdef HAS_LIBCEC
    if (!m_cecController) {
        return false;
    }
    return m_cecController->isActiveSource();
#else
    return false;
#endif
}

QString InputHandlerDBus::queryDeviceOsdName(int logicalAddress)
{
#ifdef HAS_LIBCEC
    if (!m_cecController) {
        return {};
    }
    return m_cecController->queryDeviceOsdName(logicalAddress);
#else
    Q_UNUSED(logicalAddress);
    return {};
#endif
}

#include "moc_inputhandlerdbus.cpp"
