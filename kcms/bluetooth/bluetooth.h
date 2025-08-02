// SPDX-FileCopyrightText: 2025 User8395 <therealuser8395@proton.me>
// SPDX-License-Identifier: GPL-2.0-or-later

#include <BluezQt/Device>
#include <KQuickConfigModule>
#include <QObject>

class Bluetooth : public KQuickConfigModule
{
    Q_OBJECT
    Q_PROPERTY(bool fromDatabase READ isFromDatabase)
public:
    Bluetooth(QObject *parent, const KPluginMetaData &data);

    Q_INVOKABLE void setPin(const QString &pin);
    Q_INVOKABLE bool isFromDatabase();
    Q_INVOKABLE QString getPin(BluezQt::DevicePtr device);

private:
    bool m_fromDatabase = false;
    QString m_pin;
};
