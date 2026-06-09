/*
 * SPDX-FileCopyrightText: 2026 Devin Lin <devin@kde.org>
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

#include "inputsettings.h"
#include "inputhandlerinterface.h"

#include <KPluginFactory>
#include <QDBusArgument>
#include <QDBusConnection>
#include <QDBusConnectionInterface>
#include <QDBusPendingReply>
#include <QDBusVariant>
#include <QDebug>
#include <QTimer>

K_PLUGIN_CLASS_WITH_JSON(InputSettings, "kcm_mediacenter_input.json")

using namespace Qt::StringLiterals;

static const QString s_serviceName = u"org.kde.plasma.bigscreen.inputhandler"_s;
static const QString s_objectPath = u"/InputHandler"_s;

static QVariantMap controllerMapFromVariant(QVariant controller)
{
    if (controller.canConvert<QDBusVariant>()) {
        controller = controller.value<QDBusVariant>().variant();
    }

    if (controller.canConvert<QVariantMap>()) {
        return controller.toMap();
    }

    if (controller.canConvert<QDBusArgument>()) {
        QVariantMap controllerMap;
        controller.value<QDBusArgument>() >> controllerMap;
        return controllerMap;
    }

    return {};
}

static QVariantList controllerListFromDBusReply(const QVariantList &controllers)
{
    QVariantList controllerList;
    controllerList.reserve(controllers.size());

    for (QVariant controller : controllers) {
        QVariantMap controllerMap = controllerMapFromVariant(controller);
        if (!controllerMap.isEmpty()) {
            controllerList.append(controllerMap);
        }
    }

    return controllerList;
}

InputSettings::InputSettings(QObject *parent, const KPluginMetaData &data)
    : KQuickConfigModule(parent, data)
    , m_serviceWatcher(new QDBusServiceWatcher(s_serviceName,
                                               QDBusConnection::sessionBus(),
                                               QDBusServiceWatcher::WatchForRegistration | QDBusServiceWatcher::WatchForUnregistration,
                                               this))
{
    setButtons(NoAdditionalButton);

    connect(m_serviceWatcher, &QDBusServiceWatcher::serviceRegistered, this, &InputSettings::connectToService);
    connect(m_serviceWatcher, &QDBusServiceWatcher::serviceUnregistered, this, &InputSettings::disconnectFromService);

    if (QDBusConnection::sessionBus().interface()->isServiceRegistered(s_serviceName)) {
        connectToService();
    }
}

InputSettings::~InputSettings()
{
    disconnectFromService();
}

bool InputSettings::serviceAvailable() const
{
    return m_serviceAvailable;
}

bool InputSettings::enabled() const
{
    return m_enabled;
}

void InputSettings::setEnabled(bool enabled)
{
    if (!m_interface) {
        return;
    }

    m_interface->setEnabled(enabled);
    updateFromService();
}

bool InputSettings::gameControllerEnabled() const
{
    return m_gameControllerEnabled;
}

void InputSettings::setGameControllerEnabled(bool enabled)
{
    if (!m_interface) {
        return;
    }

    m_interface->setGameControllerEnabled(enabled);
    updateFromService();
}

bool InputSettings::cecEnabled() const
{
    return m_cecEnabled;
}

void InputSettings::setCecEnabled(bool enabled)
{
    if (!m_interface) {
        return;
    }

    m_interface->setCecEnabled(enabled);
    updateFromService();
}

bool InputSettings::autoSuppressInput() const
{
    return m_autoSuppressInput;
}

void InputSettings::setAutoSuppressInput(bool enabled)
{
    if (!m_interface) {
        return;
    }

    m_interface->setAutoSuppressInput(enabled);
    updateFromService();
}

QVariantList InputSettings::connectedControllers() const
{
    return m_connectedControllers;
}

void InputSettings::setControllerEnabled(const QString &uniqueIdentifier, bool enabled)
{
    if (!m_interface) {
        return;
    }

    m_interface->setControllerEnabled(uniqueIdentifier, enabled);
    updateFromService();
}

void InputSettings::setStartButtonEnabledWhenSuppressed(const QString &uniqueIdentifier, bool enabled)
{
    if (!m_interface) {
        return;
    }

    m_interface->setStartButtonEnabledWhenSuppressed(uniqueIdentifier, enabled);
    updateFromService();
}

void InputSettings::refresh()
{
    updateFromService();
}

void InputSettings::connectToService()
{
    if (m_interface) {
        return;
    }

    m_interface = new OrgKdePlasmaBigscreenInputhandlerInterface(s_serviceName, s_objectPath, QDBusConnection::sessionBus(), this);
    if (!m_interface->isValid()) {
        delete m_interface;
        m_interface = nullptr;
        return;
    }

    connect(m_interface, &OrgKdePlasmaBigscreenInputhandlerInterface::enabledChanged, this, &InputSettings::scheduleUpdateFromService);
    connect(m_interface, &OrgKdePlasmaBigscreenInputhandlerInterface::gameControllerEnabledChanged, this, &InputSettings::scheduleUpdateFromService);
    connect(m_interface, &OrgKdePlasmaBigscreenInputhandlerInterface::cecEnabledChanged, this, &InputSettings::scheduleUpdateFromService);
    connect(m_interface, &OrgKdePlasmaBigscreenInputhandlerInterface::autoSuppressInputChanged, this, &InputSettings::scheduleUpdateFromService);
    connect(m_interface, &OrgKdePlasmaBigscreenInputhandlerInterface::connectedControllersChanged, this, &InputSettings::scheduleUpdateFromService);

    m_serviceAvailable = true;
    Q_EMIT serviceAvailableChanged();

    updateFromService();
}

void InputSettings::disconnectFromService()
{
    if (m_interface) {
        delete m_interface;
        m_interface = nullptr;
    }

    if (m_serviceAvailable) {
        m_serviceAvailable = false;
        Q_EMIT serviceAvailableChanged();
    }

    if (!m_connectedControllers.isEmpty()) {
        m_connectedControllers.clear();
        Q_EMIT connectedControllersChanged();
    }
}

void InputSettings::scheduleUpdateFromService()
{
    if (m_updateScheduled) {
        return;
    }

    m_updateScheduled = true;
    QTimer::singleShot(0, this, [this]() {
        m_updateScheduled = false;
        updateFromService();
    });
}

void InputSettings::updateFromService()
{
    m_updateScheduled = false;

    if (!m_interface) {
        return;
    }

    bool enabled = m_interface->enabled();
    if (m_enabled != enabled) {
        m_enabled = enabled;
        Q_EMIT enabledChanged();
    }

    bool gameControllerEnabled = m_interface->gameControllerEnabled();
    if (m_gameControllerEnabled != gameControllerEnabled) {
        m_gameControllerEnabled = gameControllerEnabled;
        Q_EMIT gameControllerEnabledChanged();
    }

    bool cecEnabled = m_interface->cecEnabled();
    if (m_cecEnabled != cecEnabled) {
        m_cecEnabled = cecEnabled;
        Q_EMIT cecEnabledChanged();
    }

    bool autoSuppressInput = m_interface->autoSuppressInput();
    if (m_autoSuppressInput != autoSuppressInput) {
        m_autoSuppressInput = autoSuppressInput;
        Q_EMIT autoSuppressInputChanged();
    }

    QDBusPendingReply<QVariantList> reply = m_interface->connectedControllers();
    reply.waitForFinished();

    QVariantList connectedControllers;
    if (!reply.isError()) {
        connectedControllers = controllerListFromDBusReply(reply.value());
    } else {
        qWarning() << "Failed to fetch connected input controllers:" << reply.error().message();
    }
    if (m_connectedControllers != connectedControllers) {
        m_connectedControllers = connectedControllers;
        Q_EMIT connectedControllersChanged();
    }
}

#include "inputsettings.moc"
