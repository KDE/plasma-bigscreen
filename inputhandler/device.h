/*
 *   SPDX-FileCopyrightText: 2022 Bart Ribbers <bribbers@disroot.org>
 *
 *   SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

#pragma once

#include <QObject>
#include <QSet>

#include <unistd.h>

enum DeviceType {
    DeviceCEC,
    DeviceWiimote,
    DeviceGamepad,
    DeviceJoystick
};

class Device : public QObject
{
    Q_OBJECT

public:
    Device() = default;
    Device(DeviceType deviceType, QString name, QString uniqueIdentifier);
    ~Device();

    void setIndex(int index);
    QString getUniqueIdentifier();

    QString getName();
    DeviceType getDeviceType();
    QString iconName() const;

    /// needs to be called before newDevice() is called
    void setUsedKeys(const QSet<int> &keys)
    {
        m_usedKeys = keys;
    }
    QSet<int> usedKeys() const
    {
        return m_usedKeys;
    }

public Q_SLOTS:
    virtual void watchEvents()
    {
        return;
    };

Q_SIGNALS:
    void deviceDisconnected(int index);

protected:
    int m_index = -1;
    QString m_uniqueIdentifier;
    QString m_name;
    DeviceType m_deviceType;
    QSet<int> m_usedKeys;
};
