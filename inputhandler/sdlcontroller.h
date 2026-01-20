/*
 *   SPDX-FileCopyrightText: 2026 Devin Lin <devin@kde.org>
 *
 *   SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

#pragma once

#include <QMap>
#include <QObject>
#include <QSet>
#include <QTimer>

#include "device.h"
#include "devicewatcher.h"

#include <SDL3/SDL.h>

class SdlController;

class SdlDevice : public Device
{
    Q_OBJECT

public:
    explicit SdlDevice(SDL_Gamepad *gamepad, SDL_JoystickID instanceId, SdlController *controller);
    ~SdlDevice() override;

    SDL_Gamepad *gamepad() const
    {
        return m_gamepad;
    }
    SDL_JoystickID instanceId() const
    {
        return m_instanceId;
    }

    void processButtonEvent(const SDL_GamepadButtonEvent &event);
    void processAxisEvent(const SDL_GamepadAxisEvent &event);

Q_SIGNALS:
    void keyPress(int keyCode, bool pressed);

private Q_SLOTS:
    void updateMouseMovement();

private:
    void setKey(int key, bool pressed);

    SdlController *const m_controller;
    SDL_Gamepad *const m_gamepad;
    SDL_JoystickID m_instanceId;

    QSet<int> m_pressedKeys;

    // Button mappings from SDL gamepad buttons to keyboard keys
    const QMap<SDL_GamepadButton, QList<int>> m_buttons;

    // Axis state for direction tracking (left stick -> keyboard)
    int m_axisLeftXDirection = 0; // -1 left, 0 center, 1 right
    int m_axisLeftYDirection = 0; // -1 up, 0 center, 1 down

    // Right stick state for mouse movement
    double m_rightStickX = 0.0;
    double m_rightStickY = 0.0;
    QTimer *m_mouseTimer = nullptr;

    // Threshold for axis to be considered pressed (0-32767 range)
    static constexpr int AXIS_THRESHOLD = 16384;
    // Deadzone for mouse movement (smaller than keyboard threshold)
    static constexpr int MOUSE_DEADZONE = 4000;
    // Mouse sensitivity multiplier
    static constexpr double MOUSE_SENSITIVITY = 15.0;
};

class SdlController : public QObject
{
    Q_OBJECT

public:
    explicit SdlController();
    ~SdlController() override;

    bool hasConnectedControllers() const;

    void setSuppressInput(bool suppress);
    bool isSuppressInput() const
    {
        return m_suppressInput;
    }
    bool isManualSuppressInput() const
    {
        return m_manualSuppressInput;
    }

Q_SIGNALS:
    void controllerAdded(const QString &name);
    void controllerRemoved(const QString &name);
    void isSuppressInputChanged(bool suppressed, bool automatic); // automatic - whether it was changed by the DeviceWatcher

private Q_SLOTS:
    void poll();

private:
    void addDevice(SDL_JoystickID instanceId);
    void removeDevice(SDL_JoystickID instanceId);

    QMap<SDL_JoystickID, SdlDevice *> m_devices;
    QTimer *m_pollTimer = nullptr;
    bool m_suppressInput = false;
    bool m_manualSuppressInput = false; // Manually set via D-Bus
    DeviceWatcher *m_deviceWatcher = nullptr;

    // Polling intervals
    static constexpr int SHORT_POLL_INTERVAL = 16; // ~60fps when devices connected
    static constexpr int LONG_POLL_INTERVAL = 2000; // 2 seconds when no devices
};
