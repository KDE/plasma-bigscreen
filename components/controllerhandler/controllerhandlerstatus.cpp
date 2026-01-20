// SPDX-FileCopyrightText: 2026 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "controllerhandlerstatus.h"

#include <QDBusConnection>
#include <QDBusConnectionInterface>
#include <QDBusReply>

static const QString SERVICE = QStringLiteral("org.kde.plasma.bigscreen.inputhandler");
static const QString PATH = QStringLiteral("/InputHandler");
static const QString IFACE = QStringLiteral("org.kde.plasma.bigscreen.inputhandler");

ControllerHandlerStatus::ControllerHandlerStatus(QObject *parent)
    : QObject(parent)
    , m_serviceWatcher(new QDBusServiceWatcher(SERVICE,
                                               QDBusConnection::sessionBus(),
                                               QDBusServiceWatcher::WatchForRegistration | QDBusServiceWatcher::WatchForUnregistration,
                                               this))
{
    connect(m_serviceWatcher, &QDBusServiceWatcher::serviceRegistered, this, &ControllerHandlerStatus::connectToService);
    connect(m_serviceWatcher, &QDBusServiceWatcher::serviceUnregistered, this, &ControllerHandlerStatus::disconnectFromService);

    if (QDBusConnection::sessionBus().interface()->isServiceRegistered(SERVICE)) {
        connectToService();
    }
}

ControllerHandlerStatus::~ControllerHandlerStatus()
{
    disconnectFromService();
}

void ControllerHandlerStatus::connectToService()
{
    if (m_dbusInterface) {
        return;
    }

    m_dbusInterface = new QDBusInterface(SERVICE, PATH, IFACE, QDBusConnection::sessionBus(), this);

    if (!m_dbusInterface->isValid()) {
        qWarning() << "Failed to connect to InputHandler DBus interface:" << m_dbusInterface->lastError().message();
        delete m_dbusInterface;
        m_dbusInterface = nullptr;
        return;
    }

    auto bus = QDBusConnection::sessionBus();
    bus.connect(SERVICE, PATH, IFACE, QStringLiteral("sdlControllerAdded"), this, SLOT(onSdlControllerAdded(QString)));
    bus.connect(SERVICE, PATH, IFACE, QStringLiteral("sdlControllerRemoved"), this, SLOT(onSdlControllerRemoved(QString)));
    bus.connect(SERVICE, PATH, IFACE, QStringLiteral("cecControllerAdded"), this, SLOT(onCecControllerAdded(QString)));
    bus.connect(SERVICE, PATH, IFACE, QStringLiteral("cecControllerRemoved"), this, SLOT(onCecControllerRemoved(QString)));
    bus.connect(SERVICE, PATH, IFACE, QStringLiteral("inputSuppressedChanged"), this, SLOT(onInputSuppressedChanged(bool)));
    bus.connect(SERVICE, PATH, IFACE, QStringLiteral("homeActionRequested"), this, SIGNAL(homeActionRequested()));

    m_serviceAvailable = true;
    Q_EMIT serviceAvailableChanged();

    updateConnectionStatus();
}

void ControllerHandlerStatus::disconnectFromService()
{
    if (m_dbusInterface) {
        auto bus = QDBusConnection::sessionBus();
        bus.disconnect(SERVICE, PATH, IFACE, QStringLiteral("sdlControllerAdded"), this, SLOT(onSdlControllerAdded(QString)));
        bus.disconnect(SERVICE, PATH, IFACE, QStringLiteral("sdlControllerRemoved"), this, SLOT(onSdlControllerRemoved(QString)));
        bus.disconnect(SERVICE, PATH, IFACE, QStringLiteral("cecControllerAdded"), this, SLOT(onCecControllerAdded(QString)));
        bus.disconnect(SERVICE, PATH, IFACE, QStringLiteral("cecControllerRemoved"), this, SLOT(onCecControllerRemoved(QString)));
        bus.disconnect(SERVICE, PATH, IFACE, QStringLiteral("inputSuppressedChanged"), this, SLOT(onInputSuppressedChanged(bool)));
        bus.disconnect(SERVICE, PATH, IFACE, QStringLiteral("homeActionRequested"), this, SIGNAL(homeActionRequested()));

        delete m_dbusInterface;
        m_dbusInterface = nullptr;
    }

    if (m_serviceAvailable) {
        m_serviceAvailable = false;
        Q_EMIT serviceAvailableChanged();
    }
}

void ControllerHandlerStatus::updateConnectionStatus()
{
    if (!m_dbusInterface) {
        return;
    }

    bool newSdlConnected = isSdlControllerConnected();
    bool newCecConnected = isCecControllerConnected();
    bool newInputSuppressed = m_dbusInterface->property("inputSuppressed").toBool();

    if (newSdlConnected != m_sdlControllerConnected) {
        m_sdlControllerConnected = newSdlConnected;
        Q_EMIT sdlControllerConnectedChanged();
    }

    if (newCecConnected != m_cecControllerConnected) {
        m_cecControllerConnected = newCecConnected;
        Q_EMIT cecControllerConnectedChanged();
    }

    if (newInputSuppressed != m_inputSuppressed) {
        m_inputSuppressed = newInputSuppressed;
        Q_EMIT inputSuppressedChanged();
    }
}

bool ControllerHandlerStatus::sdlControllerConnected() const
{
    return m_sdlControllerConnected;
}
bool ControllerHandlerStatus::cecControllerConnected() const
{
    return m_cecControllerConnected;
}
bool ControllerHandlerStatus::serviceAvailable() const
{
    return m_serviceAvailable;
}
bool ControllerHandlerStatus::inputSuppressed() const
{
    return m_inputSuppressed;
}

void ControllerHandlerStatus::setInputSuppressed(bool suppress)
{
    if (m_dbusInterface && m_inputSuppressed != suppress) {
        m_dbusInterface->setProperty("inputSuppressed", suppress);
    }
}

bool ControllerHandlerStatus::isSdlControllerConnected()
{
    if (!m_dbusInterface)
        return false;
    QDBusReply<bool> reply = m_dbusInterface->call(QStringLiteral("isSdlControllerConnected"));
    return reply.isValid() ? reply.value() : false;
}

bool ControllerHandlerStatus::isCecControllerConnected()
{
    if (!m_dbusInterface)
        return false;
    QDBusReply<bool> reply = m_dbusInterface->call(QStringLiteral("isCecControllerConnected"));
    return reply.isValid() ? reply.value() : false;
}

void ControllerHandlerStatus::onSdlControllerAdded(const QString &name)
{
    m_sdlControllerConnected = true;
    Q_EMIT sdlControllerConnectedChanged();
    Q_EMIT sdlControllerAdded(name);
}

void ControllerHandlerStatus::onSdlControllerRemoved(const QString &name)
{
    m_sdlControllerConnected = isSdlControllerConnected();
    Q_EMIT sdlControllerConnectedChanged();
    Q_EMIT sdlControllerRemoved(name);
}

void ControllerHandlerStatus::onCecControllerAdded(const QString &name)
{
    m_cecControllerConnected = true;
    Q_EMIT cecControllerConnectedChanged();
    Q_EMIT cecControllerAdded(name);
}

void ControllerHandlerStatus::onCecControllerRemoved(const QString &name)
{
    m_cecControllerConnected = isCecControllerConnected();
    Q_EMIT cecControllerConnectedChanged();
    Q_EMIT cecControllerRemoved(name);
}

void ControllerHandlerStatus::onInputSuppressedChanged(bool suppressed)
{
    if (m_inputSuppressed != suppressed) {
        m_inputSuppressed = suppressed;
        Q_EMIT inputSuppressedChanged();
    }
}

#include "moc_controllerhandlerstatus.cpp"
