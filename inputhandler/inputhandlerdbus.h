/*
 *   SPDX-FileCopyrightText: 2026 Devin Lin <devin@kde.org>
 *
 *   SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

#pragma once

#include <QList>
#include <QObject>
#include <QString>
#include <QVariantList>
#include <QVariantMap>

class SdlController;

#ifdef HAS_LIBCEC
class CECController;
#endif

class InputHandlerDBus : public QObject
{
    Q_OBJECT
    Q_CLASSINFO("D-Bus Interface", "org.kde.plasma.bigscreen.inputhandler")
    Q_PROPERTY(bool inputSuppressed READ isInputSuppressed WRITE setInputSuppressed NOTIFY inputSuppressedChanged)
    Q_PROPERTY(bool inputManuallySuppressed READ isInputManuallySuppressed NOTIFY inputSuppressedChanged)
    Q_PROPERTY(bool autoSuppressInput READ autoSuppressInput WRITE setAutoSuppressInput NOTIFY autoSuppressInputChanged)
    Q_PROPERTY(bool enabled READ isEnabled WRITE setEnabled NOTIFY enabledChanged)
    Q_PROPERTY(bool gameControllerEnabled READ isGameControllerEnabled WRITE setGameControllerEnabled NOTIFY gameControllerEnabledChanged)
    Q_PROPERTY(bool cecEnabled READ isCecEnabled WRITE setCecEnabled NOTIFY cecEnabledChanged)

public:
    explicit InputHandlerDBus(QObject *parent = nullptr);
    ~InputHandlerDBus() override;

    void setSdlController(SdlController *controller);

#ifdef HAS_LIBCEC
    void setCecController(CECController *controller);
#endif

    bool isInputSuppressed() const;
    bool isInputManuallySuppressed() const;
    void setInputSuppressed(bool suppress);
    bool autoSuppressInput() const;
    void setAutoSuppressInput(bool enabled);

    bool isEnabled() const;
    void setEnabled(bool enabled);

    bool isGameControllerEnabled() const;
    void setGameControllerEnabled(bool enabled);

    bool isCecEnabled() const;
    void setCecEnabled(bool enabled);

public Q_SLOTS:
    // DBus methods
    Q_SCRIPTABLE bool isSdlControllerConnected() const;
    Q_SCRIPTABLE bool isCecControllerConnected() const;
    Q_SCRIPTABLE QVariantList connectedControllers() const;
    Q_SCRIPTABLE void setControllerEnabled(const QString &uniqueIdentifier, bool enabled);
    Q_SCRIPTABLE void setStartButtonEnabledWhenSuppressed(const QString &uniqueIdentifier, bool enabled);

    // Outbound CEC commands. logicalAddress is the CEC logical address
    // of the target device (0 = TV, see CEC spec table 10-6). Returns
    // false (or CEC_POWER_STATUS_UNKNOWN for queryDevicePowerStatus,
    // CECDEVICE_UNKNOWN for queryActiveSource, an empty string for
    // queryDeviceOsdName) if libcec is not initialised, no adapter is
    // open, or the build does not include libcec support.
    Q_SCRIPTABLE bool sendStandby(int logicalAddress);
    Q_SCRIPTABLE bool sendImageViewOn(int logicalAddress);
    Q_SCRIPTABLE bool sendActiveSource();
    Q_SCRIPTABLE int queryDevicePowerStatus(int logicalAddress);
    Q_SCRIPTABLE int queryActiveSource();
    Q_SCRIPTABLE bool isActiveSource();
    Q_SCRIPTABLE QString queryDeviceOsdName(int logicalAddress);

Q_SIGNALS:
    // DBus signals
    Q_SCRIPTABLE void sdlControllerAdded(const QString &name);
    Q_SCRIPTABLE void sdlControllerRemoved(const QString &name);
    Q_SCRIPTABLE void cecControllerAdded(const QString &name);
    Q_SCRIPTABLE void cecControllerRemoved(const QString &name);
    Q_SCRIPTABLE void inputSuppressedChanged(bool suppressed, bool automatic);
    Q_SCRIPTABLE void autoSuppressInputChanged(bool enabled);
    Q_SCRIPTABLE void homeActionRequested();
    Q_SCRIPTABLE void enabledChanged(bool enabled);
    Q_SCRIPTABLE void gameControllerEnabledChanged(bool enabled);
    Q_SCRIPTABLE void cecEnabledChanged(bool enabled);
    Q_SCRIPTABLE void connectedControllersChanged();

private:
    SdlController *m_sdlController = nullptr;

#ifdef HAS_LIBCEC
    CECController *m_cecController = nullptr;
#endif
};
