/*
    SPDX-FileCopyrightText: 2021 Aditya Mehra <aix.m@outlook.com>
    SPDX-FileCopyrightText: 2025 Seshan Ravikumar <seshan@sineware.ca>

    SPDX-License-Identifier: MIT
*/

#include "global.h"

#include <fcntl.h>
#include <unistd.h>

#include <QDBusConnection>
#include <QDBusMessage>
#include <QDBusPendingCall>
#include <QDBusPendingCallWatcher>
#include <QDBusPendingReply>
#include <QDBusUnixFileDescriptor>
#include <QDateTime>
#include <QDir>
#include <QFile>
#include <QFutureWatcher>
#include <QGuiApplication>
#include <QImage>
#include <QScreen>
#include <QStandardPaths>
#include <QtConcurrent/QtConcurrentRun>
#include <qstringliteral.h>

#include <KLocalizedString>

using namespace Qt::Literals::StringLiterals;

static QImage allocateImage(const QVariantMap &metadata)
{
    bool ok;

    const uint width = metadata.value(QStringLiteral("width")).toUInt(&ok);
    if (!ok) {
        return QImage();
    }

    const uint height = metadata.value(QStringLiteral("height")).toUInt(&ok);
    if (!ok) {
        return QImage();
    }

    const uint format = metadata.value(QStringLiteral("format")).toUInt(&ok);
    if (!ok) {
        return QImage();
    }

    return QImage(width, height, QImage::Format(format));
}

static QImage readImage(int fileDescriptor, const QVariantMap &metadata)
{
    QFile file;
    if (!file.open(fileDescriptor, QFileDevice::ReadOnly, QFileDevice::AutoCloseHandle)) {
        close(fileDescriptor);
        return QImage();
    }

    QImage result = allocateImage(metadata);
    if (result.isNull()) {
        return QImage();
    }

    QDataStream stream(&file);
    stream.readRawData(reinterpret_cast<char *>(result.bits()), result.sizeInBytes());

    return result;
}

Global::Global(QObject *parent)
    : QObject(parent)
{
    m_screenshotInterface = new OrgKdeKWinScreenShot2Interface(QStringLiteral("org.kde.KWin.ScreenShot2"),
                                                               QStringLiteral("/org/kde/KWin/ScreenShot2"),
                                                               QDBusConnection::sessionBus(),
                                                               this);
}

void Global::promptLogoutGreeter(const QString message)
{
    QDBusMessage msg = QDBusMessage::createMethodCall(QStringLiteral("org.kde.LogoutPrompt"),
                                                      QStringLiteral("/LogoutPrompt"),
                                                      QStringLiteral("org.kde.LogoutPrompt"),
                                                      message);
    QDBusConnection::sessionBus().asyncCall(msg);
}

QString Global::launchReason() const
{
    const QString launchReason = qgetenv("PLASMA_BIGSCREEN_LAUNCH_REASON");
    if (launchReason.isEmpty()) {
        return QStringLiteral("default");
    }
    return launchReason;
}

void Global::takeScreenshot()
{
    int pipeFds[2];
    if (pipe2(pipeFds, O_CLOEXEC) != 0) {
        qWarning() << "Could not take screenshot";
        return;
    }

    QVariantMap options;
    options.insert(QStringLiteral("native-resolution"), true);
    options.insert(QStringLiteral("hide-caller-windows"), false);

    auto pendingCall = m_screenshotInterface->CaptureScreen(qGuiApp->screens().constFirst()->name(), options, QDBusUnixFileDescriptor(pipeFds[1]));
    close(pipeFds[1]);
    auto pipeFileDescriptor = pipeFds[0];

    auto watcher = new QDBusPendingCallWatcher(pendingCall, this);
    connect(watcher, &QDBusPendingCallWatcher::finished, this, [this, watcher, pipeFileDescriptor]() {
        watcher->deleteLater();
        const QDBusPendingReply<QVariantMap> reply = *watcher;

        if (reply.isError()) {
            qWarning() << "Screenshot request failed:" << reply.error().message();
        } else {
            handleScreenshotMetaDataReceived(reply, pipeFileDescriptor);
        }
    });
}

void Global::handleScreenshotMetaDataReceived(const QVariantMap &metadata, int fd)
{
    const QString type = metadata.value(QStringLiteral("type")).toString();
    if (type != QLatin1String("raw")) {
        qWarning() << "Unsupported metadata type:" << type;
        return;
    }

    auto watcher = new QFutureWatcher<QImage>(this);
    connect(watcher, &QFutureWatcher<QImage>::finished, this, [watcher]() {
        watcher->deleteLater();

        QString filePath = QStandardPaths::writableLocation(QStandardPaths::PicturesLocation);
        if (filePath.isEmpty()) {
            qWarning() << "Couldn't find a writable location for the screenshot!";
            return;
        }
        QDir picturesDir(filePath);
        if (!picturesDir.mkpath(QStringLiteral("Screenshots"))) {
            qWarning() << "Couldn't create folder at" << picturesDir.path() + QStringLiteral("/Screenshots") << "to take screenshot.";
            return;
        }
        filePath += QStringLiteral("/Screenshots/Screenshot_%1.png").arg(QDateTime::currentDateTime().toString(QStringLiteral("yyyyMMdd_hhmmss")));
        const auto result = watcher->result();
        if (result.isNull() || !result.save(filePath)) {
            qWarning() << "Screenshot failed";
        } else {
            QDBusMessage osd = QDBusMessage::createMethodCall(QStringLiteral("org.kde.plasmashell"),
                                                              QStringLiteral("/org/kde/osdService"),
                                                              QStringLiteral("org.kde.osdService"),
                                                              QStringLiteral("showText"));
            osd.setArguments({QStringLiteral("spectacle"), i18n("Screenshot saved to %1", filePath)});
            QDBusConnection::sessionBus().call(osd, QDBus::NoBlock);
        }
    });
    watcher->setFuture(QtConcurrent::run(readImage, fd, metadata));
}

void Global::swapSession()
{
    QProcess process;

    const QString path = u"PATH="_s + qgetenv("PATH");
    const QString home = u"HOME="_s + qgetenv("HOME");
    const QString plasmaBigscreenLaunchReason = u"PLASMA_BIGSCREEN_LAUNCH_REASON="_s + launchReason();
    const QString xdgCurrentDesktop = u"XDG_CURRENT_DESKTOP=KDE"_s;

    process.startDetached(u"env"_s,
                          QStringList() << u"-i"_s << path << home << plasmaBigscreenLaunchReason << xdgCurrentDesktop << u"plasma-bigscreen-swap-session"_s);
}
