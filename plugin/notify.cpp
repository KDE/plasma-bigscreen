/*
 *   Copyright (C) 2016 by Aditya Mehra <aix.m@outlook.com>                      *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#include "notify.h"
#include <QIcon>
#include <KNotification>
#include <KLocalizedString>

Notify::Notify(QObject *parent)
    : QObject(parent)
{
}

void Notify::mycroftResponse(const QString &title, const QString &notiftext)
{
    KNotification *notification = new KNotification(QStringLiteral("MycroftResponse"),
                                                    KNotification::CloseOnTimeout, this);
    notification->setComponentName(QStringLiteral("mycroftPlasmoid"));
    notification->setTitle(title);
    notification->setText(notiftext);
    notification->setActions(QStringList() << i18n("Stop") << i18n("Show Response"));
    connect(notification, &KNotification::action1Activated, this, &Notify::notificationStopSpeech);
    connect(notification, &KNotification::action2Activated, this, &Notify::notificationShowResponse);
    notification->sendEvent();
}

void Notify::mycroftConnectionStatus(const QString &connectionStatus)
{
    KNotification *notification = new KNotification(QStringLiteral("MycroftConnectionStatus"),
                                                    KNotification::CloseOnTimeout, this);
    notification->setComponentName(QStringLiteral("mycroftPlasmoid"));
    notification->setTitle(i18n("Mycroft"));
    notification->setText(connectionStatus);
    if(connectionStatus == QStringLiteral("Connected")){
        notification->setIconName("mycroft-appicon-connected");
    }
    else if(connectionStatus == QStringLiteral("Disconnected")){
        notification->setIconName("mycroft-appicon-disconnected");
    }
    else {
        notification->setIconName("mycroft-plasma-appicon");
    }
    notification->sendEvent();
}
