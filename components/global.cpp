/*
    SPDX-FileCopyrightText: 2021 Aditya Mehra <aix.m@outlook.com>

    SPDX-License-Identifier: MIT
*/

#include "global.h"
#include <QDBusConnection>
#include <QDBusMessage>
#include <QDBusPendingCall>

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