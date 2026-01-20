/*
 *   SPDX-FileCopyrightText: 2026 Devin Lin <devin@kde.org>
 *
 *   SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

#include "xdgremotedesktopsystem.h"

#include <QDBusConnection>
#include <QDBusInterface>
#include <QDBusPendingCallWatcher>
#include <QDBusPendingReply>
#include <QRandomGenerator>

constexpr uint DEVICE_KEYBOARD = 1;
constexpr uint DEVICE_POINTER = 2;
constexpr uint DEVICE_ALL = DEVICE_KEYBOARD | DEVICE_POINTER;

XdgRemoteDesktopSystem::XdgRemoteDesktopSystem()
    : AbstractSystem()
{
}

XdgRemoteDesktopSystem::~XdgRemoteDesktopSystem()
{
}

bool XdgRemoteDesktopSystem::init()
{
    m_iface = new QDBusInterface(QStringLiteral("org.freedesktop.portal.Desktop"),
                                 QStringLiteral("/org/freedesktop/portal/desktop"),
                                 QStringLiteral("org.freedesktop.portal.RemoteDesktop"),
                                 QDBusConnection::sessionBus(),
                                 this);

    if (!m_iface->isValid()) {
        qWarning() << "XDG Remote Desktop: Could not create portal interface";
        return false;
    }

    createSession();
    qDebug() << "XDG Remote Desktop: Using portal input system";
    return true;
}

QString XdgRemoteDesktopSystem::getRequestPath(const QString &token)
{
    QString sender = QDBusConnection::sessionBus().baseService();
    sender.replace(QLatin1Char('.'), QLatin1Char('_'));
    sender.replace(QLatin1Char(':'), QLatin1Char('_'));
    if (sender.startsWith(QLatin1Char('_'))) {
        sender = sender.mid(1);
    }
    return QStringLiteral("/org/freedesktop/portal/desktop/request/%1/%2").arg(sender, token);
}

void XdgRemoteDesktopSystem::createSession()
{
    if (isSessionReady() || m_connecting) {
        return;
    }
    m_connecting = true;

    const auto token = QStringLiteral("bigscreen%1").arg(QRandomGenerator::global()->generate());
    const auto sessionToken = QStringLiteral("session%1").arg(QRandomGenerator::global()->generate());
    const QString requestPath = getRequestPath(token);

    // Connect to Response signal BEFORE making the call to avoid race condition
    QDBusConnection::sessionBus().connect(QString(),
                                          requestPath,
                                          QStringLiteral("org.freedesktop.portal.Request"),
                                          QStringLiteral("Response"),
                                          this,
                                          SLOT(handleSessionCreated(uint, QVariantMap)));

    m_iface->asyncCall(QStringLiteral("CreateSession"),
                       QVariantMap{{QStringLiteral("session_handle_token"), sessionToken}, {QStringLiteral("handle_token"), token}});
}

void XdgRemoteDesktopSystem::handleSessionCreated(uint code, const QVariantMap &results)
{
    if (code != 0) {
        qWarning() << "XDG Remote Desktop: Session creation failed:" << code;
        m_connecting = false;
        return;
    }

    m_sessionPath = QDBusObjectPath(results.value(QStringLiteral("session_handle")).toString());

    // Monitor session closure
    QDBusConnection::sessionBus().connect(QString(),
                                          m_sessionPath.path(),
                                          QStringLiteral("org.freedesktop.portal.Session"),
                                          QStringLiteral("Closed"),
                                          this,
                                          SLOT(handleSessionClosed(uint, QVariantMap)));

    // Select devices
    const auto token = QStringLiteral("bigscreen%1").arg(QRandomGenerator::global()->generate());
    const QString requestPath = getRequestPath(token);

    QDBusConnection::sessionBus().connect(QString(),
                                          requestPath,
                                          QStringLiteral("org.freedesktop.portal.Request"),
                                          QStringLiteral("Response"),
                                          this,
                                          SLOT(handleDevicesSelected(uint, QVariantMap)));

    m_iface->asyncCall(QStringLiteral("SelectDevices"),
                       QVariant::fromValue(m_sessionPath),
                       QVariantMap{{QStringLiteral("handle_token"), token}, {QStringLiteral("types"), QVariant::fromValue<uint>(DEVICE_ALL)}});
}

void XdgRemoteDesktopSystem::handleDevicesSelected(uint code, const QVariantMap &results)
{
    Q_UNUSED(results)

    if (code != 0) {
        qWarning() << "XDG Remote Desktop: Device selection failed:" << code;
        m_connecting = false;
        return;
    }

    // Start the session
    const auto token = QStringLiteral("bigscreen%1").arg(QRandomGenerator::global()->generate());
    const QString requestPath = getRequestPath(token);

    QDBusConnection::sessionBus().connect(QString(),
                                          requestPath,
                                          QStringLiteral("org.freedesktop.portal.Request"),
                                          QStringLiteral("Response"),
                                          this,
                                          SLOT(handleSessionStarted(uint, QVariantMap)));

    m_iface->asyncCall(QStringLiteral("Start"), QVariant::fromValue(m_sessionPath), QString(), QVariantMap{{QStringLiteral("handle_token"), token}});
}

void XdgRemoteDesktopSystem::handleSessionStarted(uint code, const QVariantMap &results)
{
    m_connecting = false;

    if (code != 0) {
        qWarning() << "XDG Remote Desktop: Session start failed:" << code;
        return;
    }

    m_sessionStarted = true;
    uint devices = results.value(QStringLiteral("devices")).toUInt();
    qDebug() << "XDG Remote Desktop: Session started, devices:" << devices;
}

void XdgRemoteDesktopSystem::handleSessionClosed(uint code, const QVariantMap &results)
{
    Q_UNUSED(code)
    Q_UNUSED(results)

    m_sessionPath = QDBusObjectPath();
    m_sessionStarted = false;
    m_connecting = false;
}

bool XdgRemoteDesktopSystem::isSessionReady() const
{
    return m_sessionStarted && !m_sessionPath.path().isEmpty();
}

void XdgRemoteDesktopSystem::emitKey(int key, bool pressed)
{
    if (!isSessionReady()) {
        createSession();
        return;
    }
    qDebug() << "XDG Remote Desktop: key" << key << (pressed ? "pressed" : "released");
    m_iface->call(QStringLiteral("NotifyKeyboardKeycode"), QVariant::fromValue(m_sessionPath), QVariantMap(), key, pressed ? 1u : 0u);
}

void XdgRemoteDesktopSystem::emitPointerMotion(double deltaX, double deltaY)
{
    if (!isSessionReady()) {
        createSession();
        return;
    }
    qDebug() << "XDG Remote Desktop: pointer motion" << deltaX << deltaY;
    m_iface->call(QStringLiteral("NotifyPointerMotion"), QVariant::fromValue(m_sessionPath), QVariantMap(), deltaX, deltaY);
}

void XdgRemoteDesktopSystem::emitPointerButton(int button, bool pressed)
{
    if (!isSessionReady()) {
        createSession();
        return;
    }
    qDebug() << "XDG Remote Desktop: button" << button << (pressed ? "pressed" : "released");
    m_iface->call(QStringLiteral("NotifyPointerButton"), QVariant::fromValue(m_sessionPath), QVariantMap(), button, pressed ? 1u : 0u);
}

#include "moc_xdgremotedesktopsystem.cpp"
