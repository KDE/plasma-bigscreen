/*
 *   SPDX-FileCopyrightText: 2022 Bart Ribbers <bribbers@disroot.org>
 *
 *   SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

#include "device.h"

#include <QDebug>

Device::Device(DeviceType deviceType, QString name, QString uniqueIdentifier)
    : m_uniqueIdentifier(uniqueIdentifier)
    , m_name(name)
    , m_deviceType(deviceType)
{
}

void Device::setIndex(int index)
{
    if (m_index < 0) {
        m_index = index;
    }
}

QString Device::getUniqueIdentifier()
{
    return m_uniqueIdentifier;
}

QString Device::getName()
{
    return m_name;
}

DeviceType Device::getDeviceType()
{
    return m_deviceType;
}

QString Device::iconName() const
{
    return m_deviceType == DeviceCEC ? "" : "input-gamepad";
}

Device::~Device() = default;

#include "moc_device.cpp"
