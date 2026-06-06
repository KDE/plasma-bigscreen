/*
 *   SPDX-FileCopyrightText: 2022 Bart Ribbers <bribbers@disroot.org>
 *
 *   SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

#pragma once

#include "device.h"
#include <QHash>
#include <QObject>
#include <QScopedPointer>
#include <QSet>
#include <QString>
#include <QVariantList>
#include <QVariantMap>

class XdgRemoteDesktopSystem;

class ControllerManager : public QObject
{
    Q_OBJECT

public:
    explicit ControllerManager(QObject *parent = nullptr);
    ~ControllerManager();
    static ControllerManager &instance();

    void newDevice(Device *device);
    void deviceRemoved(Device *device);
    bool isConnected(const QString &uniqueIdentifier) const;

    /** Have input forward events to the OS */
    void resetInputSystem();

    bool enabled() const;
    void setEnabled(bool enabled);

    bool gameControllerEnabled() const;
    void setGameControllerEnabled(bool enabled);

    bool cecEnabled() const;
    void setCecEnabled(bool enabled);

    bool controllerEnabled(const QString &uniqueIdentifier) const;
    void setControllerEnabled(const QString &uniqueIdentifier, bool enabled);

    bool startButtonEnabledWhenSuppressed(const QString &uniqueIdentifier) const;
    void setStartButtonEnabledWhenSuppressed(const QString &uniqueIdentifier, bool enabled);

    QVariantList connectedControllers() const;
    void releasePressedInput(Device *device);

public Q_SLOTS:
    void emitKey(int key, bool pressed);
    void emitPointerMotion(double deltaX, double deltaY);
    void emitPointerButton(int button, bool pressed);
    void emitKey(Device *device, int key, bool pressed);
    void emitPointerMotion(Device *device, double deltaX, double deltaY);
    void emitPointerButton(Device *device, int button, bool pressed);
    void emitHomeAction();
    void emitHomeAction(Device *device);
    void removeDevice(int deviceIndex);

Q_SIGNALS:
    void deviceConnected(Device *);
    void deviceDisconnected(Device *);
    void homeActionRequested();
    void enabledChanged(bool enabled);
    void gameControllerEnabledChanged(bool enabled);
    void cecEnabledChanged(bool enabled);
    void connectedControllersChanged();

private:
    bool deviceAllowed(Device *device) const;
    Device *deviceForUniqueIdentifier(const QString &uniqueIdentifier) const;
    void releaseAllPressedInput();
    void releasePressedInput(DeviceType type);

    bool m_enabled = true;
    bool m_gameControllerEnabled = true;
    bool m_cecEnabled = true;
    QSet<QString> m_disabledControllers;
    QSet<QString> m_startButtonDisabledWhenSuppressedControllers;
    QVector<Device *> m_connectedDevices;
    QScopedPointer<XdgRemoteDesktopSystem> m_inputSystem;

    QHash<Device *, QSet<int>> m_pressedKeys;
    QHash<Device *, QSet<int>> m_pressedPointerButtons;
    QSet<int> m_pressedKeysWithoutDevice;
    QSet<int> m_pressedPointerButtonsWithoutDevice;
};
