/*
 *   SPDX-FileCopyrightText: 2026 Devin Lin <devin@kde.org>
 *
 *   SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

#include "inputhandlerdbus.h"
#include "controllermanager.h"
#include "sdlcontroller.h"

#ifdef HAS_LIBCEC
#include "libcec/ceccontroller.h"
#endif

#include <QDBusConnection>
#include <QDBusError>
#include <QDebug>

InputHandlerDBus::InputHandlerDBus(QObject *parent)
    : QObject(parent)
{
    QDBusConnection sessionBus = QDBusConnection::sessionBus();

    if (!sessionBus.registerService(QStringLiteral("org.kde.plasma.bigscreen.inputhandler"))) {
        qWarning() << "Failed to register DBus service org.kde.plasma.bigscreen.inputhandler:" << sessionBus.lastError().message();
    }

    if (!sessionBus.registerObject(QStringLiteral("/InputHandler"),
                                   this,
                                   QDBusConnection::ExportScriptableSlots | QDBusConnection::ExportScriptableSignals | QDBusConnection::ExportAllProperties)) {
        qWarning() << "Failed to register DBus object /InputHandler:" << sessionBus.lastError().message();
    }

    connect(&ControllerManager::instance(), &ControllerManager::homeActionRequested, this, &InputHandlerDBus::homeActionRequested);

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

void InputHandlerDBus::setInputSuppressed(bool suppress)
{
    if (!m_sdlController) {
        return;
    }
    m_sdlController->setSuppressInput(suppress);
}

#include "moc_inputhandlerdbus.cpp"
