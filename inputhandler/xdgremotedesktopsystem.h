/*
 *   SPDX-FileCopyrightText: 2026 Devin Lin <devin@kde.org>
 *
 *   SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

#pragma once

#include <QDBusInterface>
#include <QDBusObjectPath>

class XdgRemoteDesktopSystem : public QObject
{
    Q_OBJECT

public:
    XdgRemoteDesktopSystem();
    ~XdgRemoteDesktopSystem() override;

    bool init();
    void emitKey(int key, bool pressed);
    void emitPointerMotion(double deltaX, double deltaY);
    void emitPointerButton(int button, bool pressed);

private Q_SLOTS:
    void handleSessionCreated(uint code, const QVariantMap &results);
    void handleDevicesSelected(uint code, const QVariantMap &results);
    void handleSessionStarted(uint code, const QVariantMap &results);
    void handleSessionClosed(uint code, const QVariantMap &results);

private:
    void createSession();
    bool isSessionReady() const;
    QString getRequestPath(const QString &handleToken);

    QDBusInterface *m_iface = nullptr;
    QDBusObjectPath m_sessionPath;
    bool m_sessionStarted = false;
    bool m_connecting = false;
};
