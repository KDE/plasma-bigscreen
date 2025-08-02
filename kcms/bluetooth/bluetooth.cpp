// SPDX-FileCopyrightText: 2025 User8395 <therealuser8395@proton.me>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "bluetooth.h"
#include "devicesproxymodel.h"

#include <KPluginFactory>
#include <QAbstractItemModel>

#include <QFile>
#include <QRandomGenerator>
#include <QStandardPaths>
#include <QXmlStreamReader>

#include <BluezQt/Adapter>
#include <BluezQt/PendingCall>

K_PLUGIN_CLASS_WITH_JSON(Bluetooth, "kcm_mediacenter_bluetooth.json")

Bluetooth::Bluetooth(QObject *parent, const KPluginMetaData &data)
    : KQuickConfigModule(parent, data)
{
    setButtons(Apply);

    qmlRegisterType<DevicesProxyModel>("org.kde.plasma.bigscreen.bluetooth", 1, 0, "DevicesProxyModel");
}

void Bluetooth::setPin(const QString &pin)
{
    m_pin = pin;
    m_fromDatabase = false;
}

bool Bluetooth::isFromDatabase()
{
    return m_fromDatabase;
}

QString Bluetooth::getPin(BluezQt::DevicePtr device)
{
    m_fromDatabase = false;
    m_pin = QString::number(QRandomGenerator::global()->bounded(RAND_MAX));
    m_pin = m_pin.left(6);

    const QString &xmlPath = QStandardPaths::locate(QStandardPaths::AppDataLocation, QStringLiteral("pin-code-database.xml"));

    QFile file(xmlPath);
    if (!file.open(QIODevice::ReadOnly)) {
        return m_pin;
    }

    QXmlStreamReader xml(&file);

    QString deviceType = BluezQt::Device::typeToString(device->type());
    if (deviceType == QLatin1String("audiovideo")) {
        deviceType = QStringLiteral("audio");
    }

    while (!xml.atEnd()) {
        xml.readNext();
        if (xml.name() != QLatin1String("device")) {
            continue;
        }
        QXmlStreamAttributes attr = xml.attributes();

        if (attr.count() == 0) {
            continue;
        }

        if (attr.hasAttribute(QLatin1String("type")) && attr.value(QLatin1String("type")) != QLatin1String("any")) {
            if (deviceType != attr.value(QLatin1String("type")).toString()) {
                continue;
            }
        }

        if (attr.hasAttribute(QLatin1String("oui"))) {
            if (!device->address().startsWith(attr.value(QLatin1String("oui")).toString())) {
                continue;
            }
        }

        if (attr.hasAttribute(QLatin1String("name"))) {
            if (device->name() != attr.value(QLatin1String("name")).toString()) {
                continue;
            }
        }

        m_pin = attr.value(QLatin1String("pin")).toString();
        m_fromDatabase = true;
        if (m_pin.startsWith(QLatin1String("max:"))) {
            m_fromDatabase = false;
            int num = QStringView(m_pin).right(m_pin.length() - 4).toInt();
            m_pin = QString::number(QRandomGenerator::global()->bounded(RAND_MAX)).left(num);
        }

        return m_pin;
    }

    return m_pin;
}

#include "bluetooth.moc"