/*
 *   SPDX-FileCopyrightText: 2022 Bart Ribbers <bribbers@disroot.org>
 *   SPDX-FileCopyrightText: 2022 Aditya Mehra <aix.m@outlook.com>
 *   SPDX-FileCopyrightText: 2026 Devin Lin <devin@kde.org>
 *
 *   SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

#include "ceccontroller.h"
#include "../controllermanager.h"
#include "../device.h"
#include "cecworker.h"

#include <QDebug>

#include <KConfigGroup>
#include <KLocalizedString>
#include <KSharedConfig>
#include <QDBusMetaType>

#include <Solid/DeviceNotifier>

#include <libcec/cectypes.h>
#include <linux/input-event-codes.h>

using namespace CEC;

QHash<int, int> CECController::s_keyMap;

QDBusArgument &operator<<(QDBusArgument &arg, const cec_logical_address &address)
{
    arg.beginStructure();
    arg << static_cast<uchar>(address);
    arg.endStructure();
    return arg;
}

const QDBusArgument &operator>>(const QDBusArgument &arg, cec_logical_address &address)
{
    uchar value;
    arg.beginStructure();
    arg >> value;
    arg.endStructure();
    address = static_cast<cec_logical_address>(value);
    return arg;
}

CECController::CECController(QObject *parent)
    : QObject(parent)
{
    qDebug() << "CECController: Starting initialization";
    qDBusRegisterMetaType<cec_logical_address>();

    // Load key mappings from config
    KSharedConfigPtr config = KSharedConfig::openConfig();
    KConfigGroup group = config->group("General");

    auto map = [&group](const char *name, int cecKey, int evKey) {
        return std::make_pair<int, int>(group.readEntry(QString("Button") + name, cecKey), group.readEntry(QString("Key") + name, evKey));
    };

    s_keyMap = {
        map("Play", CEC_USER_CONTROL_CODE_PLAY, KEY_PLAY),
        map("Stop", CEC_USER_CONTROL_CODE_STOP, KEY_STOP),
        map("Pause", CEC_USER_CONTROL_CODE_PAUSE, KEY_PAUSE),
        map("Rewind", CEC_USER_CONTROL_CODE_REWIND, KEY_REWIND),
        map("Fastforward", CEC_USER_CONTROL_CODE_FAST_FORWARD, KEY_FASTFORWARD),
        map("Enter", CEC_USER_CONTROL_CODE_SELECT, KEY_ENTER),
        map("Up", CEC_USER_CONTROL_CODE_UP, KEY_UP),
        map("Down", CEC_USER_CONTROL_CODE_DOWN, KEY_DOWN),
        map("Left", CEC_USER_CONTROL_CODE_LEFT, KEY_LEFT),
        map("Right", CEC_USER_CONTROL_CODE_RIGHT, KEY_RIGHT),
        map("Number0", CEC_USER_CONTROL_CODE_NUMBER0, KEY_0),
        map("Number1", CEC_USER_CONTROL_CODE_NUMBER1, KEY_1),
        map("Number2", CEC_USER_CONTROL_CODE_NUMBER2, KEY_2),
        map("Number3", CEC_USER_CONTROL_CODE_NUMBER3, KEY_3),
        map("Number4", CEC_USER_CONTROL_CODE_NUMBER4, KEY_4),
        map("Number5", CEC_USER_CONTROL_CODE_NUMBER5, KEY_5),
        map("Number6", CEC_USER_CONTROL_CODE_NUMBER6, KEY_6),
        map("Number7", CEC_USER_CONTROL_CODE_NUMBER7, KEY_7),
        map("Number8", CEC_USER_CONTROL_CODE_NUMBER8, KEY_8),
        map("Number9", CEC_USER_CONTROL_CODE_NUMBER9, KEY_9),
        map("Blue", CEC_USER_CONTROL_CODE_F1_BLUE, KEY_BLUE),
        map("Red", CEC_USER_CONTROL_CODE_F2_RED, KEY_RED),
        map("Green", CEC_USER_CONTROL_CODE_F3_GREEN, KEY_GREEN),
        map("Yellow", CEC_USER_CONTROL_CODE_F4_YELLOW, KEY_YELLOW),
        map("ChannelUp", CEC_USER_CONTROL_CODE_CHANNEL_UP, KEY_CHANNELUP),
        map("ChannelDown", CEC_USER_CONTROL_CODE_CHANNEL_DOWN, KEY_CHANNELDOWN),
        map("Exit", CEC_USER_CONTROL_CODE_EXIT, KEY_EXIT),
        map("Back", CEC_USER_CONTROL_CODE_AN_RETURN, KEY_BACK),
        map("Home", CEC_USER_CONTROL_CODE_ROOT_MENU, KEY_HOMEPAGE),
        map("Subtitle", CEC_USER_CONTROL_CODE_SUB_PICTURE, KEY_SUBTITLE),
        map("Info", CEC_USER_CONTROL_CODE_DISPLAY_INFORMATION, KEY_INFO),
    };

    // Hotplug debounce timer
    m_hotplugTimer.setSingleShot(true);
    m_hotplugTimer.setInterval(500);
    connect(&m_hotplugTimer, &QTimer::timeout, this, &CECController::onHotplugTimeout);

    // Next key timeout
    m_nextKeyTimer.setSingleShot(true);
    m_nextKeyTimer.setInterval(30000);
    connect(&m_nextKeyTimer, &QTimer::timeout, this, &CECController::onNextKeyTimeout);

    // Create worker in dedicated thread
    m_workerThread = new QThread(this);
    m_workerThread->setObjectName(QStringLiteral("CEC Worker"));
    m_worker = new CECWorker();
    m_worker->moveToThread(m_workerThread);

    connect(m_worker, &CECWorker::initialized, this, &CECController::onWorkerInitialized);
    connect(m_worker, &CECWorker::deviceDiscovered, this, &CECController::onDeviceDiscovered);
    connect(m_worker, &CECWorker::cecKeyPressed, this, &CECController::onCecKeyPressed);
    connect(m_worker, &CECWorker::cecStandbyReceived, this, &CECController::enterStandby);
    connect(m_worker, &CECWorker::cecSourceActivated, this, &CECController::sourceActivated);
    connect(m_workerThread, &QThread::finished, m_worker, &QObject::deleteLater);

    m_workerThread->start();

    // Initialize asynchronously
    QString osdName = group.readEntry("OSDName", i18n("KDE Plasma"));
    qDebug() << "CECController: Using OSD name from config:" << osdName;
    QMetaObject::invokeMethod(m_worker, "initialize", Qt::QueuedConnection, Q_ARG(QString, osdName));

    // Listen for device hotplug
    connect(Solid::DeviceNotifier::instance(), &Solid::DeviceNotifier::deviceAdded, this, [this] {
        m_hotplugTimer.start();
    });
}

CECController::~CECController()
{
    if (m_workerThread) {
        QMetaObject::invokeMethod(m_worker, "cleanup", Qt::BlockingQueuedConnection);
        m_workerThread->quit();
        m_workerThread->wait(5000);
    }
}

void CECController::onWorkerInitialized(bool success)
{
    qDebug() << "CECController: Worker initialization" << (success ? "succeeded" : "failed");
    m_initialized = success;
    if (success) {
        QMetaObject::invokeMethod(m_worker, "discoverDevices", Qt::QueuedConnection);
    }
}

void CECController::onDeviceDiscovered(const QString &comName)
{
    qDebug() << "CECController: Device discovered at" << comName;

    if (m_connectedDevices.contains(comName)) {
        qDebug() << "CECController: Device" << comName << "already in connected devices set, skipping";
        return;
    }

    if (ControllerManager::instance().isConnected(comName)) {
        qDebug() << "CECController: Device" << comName << "already connected via ControllerManager, skipping";
        m_connectedDevices.insert(comName);
        return;
    }

    auto *device = new Device(DeviceCEC, QStringLiteral("CEC Controller"), comName);
    device->setUsedKeys(QSet<int>(s_keyMap.cbegin(), s_keyMap.cend()));
    ControllerManager::instance().newDevice(device);

    m_connectedDevices.insert(comName);
    m_adapterCount++;
    qDebug() << "CECController: Successfully registered device" << comName << "- total adapters:" << m_adapterCount;
    Q_EMIT controllerAdded(QStringLiteral("CEC Controller"));
}

void CECController::onHotplugTimeout()
{
    qDebug() << "CECController: Hotplug timeout - triggering device discovery";
    if (m_initialized) {
        QMetaObject::invokeMethod(m_worker, "discoverDevices", Qt::QueuedConnection);
    }
}

void CECController::requestNextKey()
{
    m_catchNextInput = true;
    m_nextKeyTimer.start();
}

void CECController::cancelNextKeyRequest()
{
    if (m_catchNextInput) {
        m_catchNextInput = false;
        m_nextKeyTimer.stop();
    }
}

void CECController::onNextKeyTimeout()
{
    if (m_catchNextInput) {
        m_catchNextInput = false;
        Q_EMIT nextKeyReceived(-1);
    }
}

void CECController::onCecKeyPressed(int keycode, int opcode)
{
    qDebug() << "CECController: CEC key received - keycode:" << keycode << "opcode:" << opcode;

    if (m_catchNextInput) {
        qDebug() << "CECController: Catching next input mode active, returning keycode to requester";
        m_catchNextInput = false;
        m_nextKeyTimer.stop();
        Q_EMIT nextKeyReceived(keycode);
        return;
    }

    int nativeKey = s_keyMap.value(keycode, -1);
    if (nativeKey < 0) {
        qDebug() << "CECController: No mapping found for CEC keycode" << keycode;
        return;
    }

    qDebug() << "CECController: Mapped CEC keycode" << keycode << "to native key" << nativeKey;

    if (nativeKey == KEY_HOMEPAGE) {
        qDebug() << "CECController: Home key detected, emitting home action";
        ControllerManager::instance().emitHomeAction();
        return;
    }

    if (opcode == CEC_OPCODE_USER_CONTROL_PRESSED) {
        ControllerManager::instance().emitKey(nativeKey, 1);
        ControllerManager::instance().emitKey(nativeKey, 0);
    } else if (opcode == CEC_OPCODE_USER_CONTROL_RELEASE) {
        ControllerManager::instance().emitKey(nativeKey, 0);
    }
}
