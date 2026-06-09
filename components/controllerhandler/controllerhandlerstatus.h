// SPDX-FileCopyrightText: 2026 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <QDBusInterface>
#include <QDBusServiceWatcher>
#include <QObject>
#include <qqmlregistration.h>

class ControllerHandlerStatus : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_PROPERTY(bool sdlControllerConnected READ sdlControllerConnected NOTIFY sdlControllerConnectedChanged)
    Q_PROPERTY(bool cecControllerConnected READ cecControllerConnected NOTIFY cecControllerConnectedChanged)
    Q_PROPERTY(bool serviceAvailable READ serviceAvailable NOTIFY serviceAvailableChanged)
    Q_PROPERTY(bool inputSuppressed READ inputSuppressed WRITE setInputSuppressed NOTIFY inputSuppressedChanged)
    Q_PROPERTY(bool inputManuallySuppressed READ inputManuallySuppressed NOTIFY inputSuppressedChanged)
    Q_PROPERTY(bool enabled READ enabled NOTIFY enabledChanged)
    Q_PROPERTY(bool gameControllerEnabled READ gameControllerEnabled NOTIFY gameControllerEnabledChanged)

public:
    explicit ControllerHandlerStatus(QObject *parent = nullptr);
    ~ControllerHandlerStatus() override;

    bool sdlControllerConnected() const;
    bool cecControllerConnected() const;
    bool serviceAvailable() const;
    bool inputSuppressed() const;
    bool inputManuallySuppressed() const;
    bool enabled() const;
    bool gameControllerEnabled() const;

    void setInputSuppressed(bool suppress);

    Q_INVOKABLE bool isSdlControllerConnected();
    Q_INVOKABLE bool isCecControllerConnected();

Q_SIGNALS:
    void sdlControllerConnectedChanged();
    void cecControllerConnectedChanged();
    void serviceAvailableChanged();
    void inputSuppressedChanged(bool suppressed, bool automatic);
    void enabledChanged();
    void gameControllerEnabledChanged();

    void sdlControllerAdded(const QString &name);
    void sdlControllerRemoved(const QString &name);
    void cecControllerAdded(const QString &name);
    void cecControllerRemoved(const QString &name);
    void homeActionRequested();

private Q_SLOTS:
    void connectToService();
    void disconnectFromService();
    void onSdlControllerAdded(const QString &name);
    void onSdlControllerRemoved(const QString &name);
    void onCecControllerAdded(const QString &name);
    void onCecControllerRemoved(const QString &name);
    void onInputSuppressedChanged(bool suppressed, bool automatic);
    void onEnabledChanged(bool enabled);
    void onGameControllerEnabledChanged(bool enabled);

private:
    void updateConnectionStatus();

    QDBusInterface *m_dbusInterface = nullptr;
    QDBusServiceWatcher *m_serviceWatcher = nullptr;

    bool m_sdlControllerConnected = false;
    bool m_cecControllerConnected = false;
    bool m_serviceAvailable = false;
    bool m_inputSuppressed = false;
    bool m_inputManuallySuppressed = false;
    bool m_enabled = true;
    bool m_gameControllerEnabled = true;
};
