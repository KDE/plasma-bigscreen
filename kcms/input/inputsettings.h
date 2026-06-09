/*
 * SPDX-FileCopyrightText: 2026 Devin Lin <devin@kde.org>
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

#pragma once

#include <KQuickConfigModule>
#include <QDBusServiceWatcher>
#include <QVariantList>

class OrgKdePlasmaBigscreenInputhandlerInterface;

class InputSettings : public KQuickConfigModule
{
    Q_OBJECT
    Q_PROPERTY(bool serviceAvailable READ serviceAvailable NOTIFY serviceAvailableChanged)
    Q_PROPERTY(bool enabled READ enabled WRITE setEnabled NOTIFY enabledChanged)
    Q_PROPERTY(bool gameControllerEnabled READ gameControllerEnabled WRITE setGameControllerEnabled NOTIFY gameControllerEnabledChanged)
    Q_PROPERTY(bool cecEnabled READ cecEnabled WRITE setCecEnabled NOTIFY cecEnabledChanged)
    Q_PROPERTY(bool autoSuppressInput READ autoSuppressInput WRITE setAutoSuppressInput NOTIFY autoSuppressInputChanged)
    Q_PROPERTY(QVariantList connectedControllers READ connectedControllers NOTIFY connectedControllersChanged)

public:
    InputSettings(QObject *parent, const KPluginMetaData &data);
    ~InputSettings() override;

    bool serviceAvailable() const;
    bool enabled() const;
    void setEnabled(bool enabled);

    bool gameControllerEnabled() const;
    void setGameControllerEnabled(bool enabled);

    bool cecEnabled() const;
    void setCecEnabled(bool enabled);

    bool autoSuppressInput() const;
    void setAutoSuppressInput(bool enabled);

    QVariantList connectedControllers() const;

    Q_INVOKABLE void refresh();
    Q_INVOKABLE void setControllerEnabled(const QString &uniqueIdentifier, bool enabled);
    Q_INVOKABLE void setStartButtonEnabledWhenSuppressed(const QString &uniqueIdentifier, bool enabled);

Q_SIGNALS:
    void serviceAvailableChanged();
    void enabledChanged();
    void gameControllerEnabledChanged();
    void cecEnabledChanged();
    void autoSuppressInputChanged();
    void connectedControllersChanged();

private Q_SLOTS:
    void connectToService();
    void disconnectFromService();
    void scheduleUpdateFromService();
    void updateFromService();

private:
    OrgKdePlasmaBigscreenInputhandlerInterface *m_interface = nullptr;
    QDBusServiceWatcher *m_serviceWatcher = nullptr;

    bool m_serviceAvailable = false;
    bool m_enabled = true;
    bool m_gameControllerEnabled = true;
    bool m_cecEnabled = true;
    bool m_autoSuppressInput = true;
    bool m_updateScheduled = false;
    QVariantList m_connectedControllers;
};
