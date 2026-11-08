// SPDX-FileCopyrightText: 2026 User8395 <therealuser8395@proton.me>
// SPDX-License-Identifier: GPL-2.0-only

#include <QObject>
#include <QDBusMessage>
#include <QDBusPendingReply>
#include <QDBusConnection>

#include <KService>
#include <KIO/ApplicationLauncherJob>

#include "linkredirector.h"

LinkRedirector::LinkRedirector(QObject *parent)
    : QObject(parent)
{}

QString LinkRedirector::sendUrl(QString device, QString url)
{
    QDBusMessage msg = QDBusMessage::createMethodCall(QStringLiteral("org.kde.kdeconnect"),
                                                    QLatin1String("/modules/kdeconnect/devices/%1/share").arg(device),
                                                    QStringLiteral("org.kde.kdeconnect.device.share"),
                                                    QStringLiteral("shareUrl"));
    msg.setArguments({ url });
    
    QDBusPendingReply<void> reply = QDBusConnection::sessionBus().asyncCall(msg);

    reply.waitForFinished();
    if (reply.isError()) {
        return reply.error().message();
    }
    return QStringLiteral("ok");
}

void LinkRedirector::openInBrowser(QString storageId, QString url)
{
    if (storageId.isEmpty()) {
        return;
    }

    KService::Ptr service = KService::serviceByStorageId(storageId);
    if (!service) {
        return;
    }

    KIO::ApplicationLauncherJob *job = new KIO::ApplicationLauncherJob(service);
    job->setUrls({ QUrl(url) });
    job->start();
}