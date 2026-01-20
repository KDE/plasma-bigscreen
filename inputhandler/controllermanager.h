/*
 *   SPDX-FileCopyrightText: 2022 Bart Ribbers <bribbers@disroot.org>
 *
 *   SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

#pragma once

#include "device.h"
#include "kwinfakeinputsystem.h"
#include <QDateTime>
#include <QHash>
#include <QObject>
#include <QSet>
#include <QTimer>

class AbstractSystem;

class ControllerManager : public QObject
{
    Q_OBJECT

public:
    explicit ControllerManager(QObject *parent = nullptr);
    ~ControllerManager();
    static ControllerManager &instance();

    void newDevice(Device *device);
    void deviceRemoved(Device *device);
    bool isConnected(QString uniqueIdentifier);

    /** Have input not forward events to the OS */
    void noopInput();

    /** Have input forward events to the OS */
    void resetInputSystem();

public Q_SLOTS:
    void emitKey(int key, bool pressed);
    void emitPointerMotion(double deltaX, double deltaY);
    void emitPointerButton(int button, bool pressed);
    void emitHomeAction();
    void removeDevice(int deviceIndex);
    QVector<Device *> connectedDevices();

Q_SIGNALS:
    void deviceConnected(Device *);
    void deviceDisconnected(Device *);
    void homeActionRequested();

private:
    bool appInhibited(const QString &appId) const;

    bool m_enabled = true;
    QVector<Device *> m_connectedDevices;
    QScopedPointer<AbstractSystem> m_inputSystem;
    QTimer m_lastUsed;

    QSet<int> m_usedKeys;
};
