/*
    SPDX-FileCopyrightText: 2021 Aditya Mehra <aix.m@outlook.com>
    SPDX-FileCopyrightText: 2025 Seshan Ravikumar <seshan@sineware.ca>

    SPDX-License-Identifier: MIT
*/

#include "global.h"
#include <QDBusConnection>
#include <QDBusMessage>
#include <QDBusPendingCall>
#include <qstringliteral.h>

using namespace Qt::Literals::StringLiterals;
 

Global::Global(QObject *parent)
    : QObject(parent)
{
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

void Global::swapSession()
{
    QProcess *process = new QProcess();

    const QString path = u"PATH="_s + qgetenv("PATH");
    const QString home = u"HOME="_s + qgetenv("HOME");
    const QString plasmaBigscreenLaunchReason = u"PLASMA_BIGSCREEN_LAUNCH_REASON="_s + launchReason();
    const QString xdgCurrentDesktop = u"XDG_CURRENT_DESKTOP=KDE"_s;

    process->startDetached(u"env"_s,
        QStringList() << u"-i"_s << path << home << plasmaBigscreenLaunchReason << xdgCurrentDesktop << u"plasma-bigscreen-swap-session"_s
    );
}