/***************************************************************************
 *   Copyright (C) 2019 Marco Martin <mart@kde.org>                        *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 ***************************************************************************/

#include "biglauncherhomescreen.h"
#include "biglauncher_dbus.h"
#include "applicationlistmodel.h"
#include "voiceapplistmodel.h"
#include "gamesapplistmodel.h"

#include <QDebug>
#include <QProcess>
#include <QtQml>

HomeScreen::HomeScreen(QObject *parent, const QVariantList &args)
    : Plasma::Containment(parent, args)
{
    const QByteArray uri("org.kde.private.biglauncher");
    qmlRegisterUncreatableType<ApplicationListModel>(uri, 1, 0, "ApplicationListModel", QStringLiteral("Cannot create an item of type ApplicationListModel"));
    qmlRegisterUncreatableType<VoiceAppListModel>(uri, 1, 0, "VoiceAppListModel", QStringLiteral("Cannot create an item of type VoiceAppListModel"));
    qmlRegisterUncreatableType<GamesAppListModel>(uri, 1, 0, "GamesAppListModel", QStringLiteral("Cannot create an item of type GamesAppListModel"));

    //setHasConfigurationInterface(true);
    auto bigLauncherDbusAdapterInterface = new BigLauncherDbusAdapterInterface(this);
    m_applicationListModel = new ApplicationListModel(this);
    m_voiceAppListModel = new VoiceAppListModel(this);
    m_gamesAppListModel = new GamesAppListModel(this);
}

HomeScreen::~HomeScreen()
{}

ApplicationListModel *HomeScreen::applicationListModel() const
{
    return m_applicationListModel;
}

VoiceAppListModel *HomeScreen::voiceAppListModel() const
{
    return m_voiceAppListModel;
}

GamesAppListModel *HomeScreen::gamesAppListModel() const
{
    return m_gamesAppListModel;
}

void HomeScreen::executeCommand(const QString &command)
{
    qWarning()<<"Executing"<<command;
    QProcess::startDetached(command);
}

K_EXPORT_PLASMA_APPLET_WITH_JSON(homescreen, HomeScreen, "metadata.json")

#include "biglauncherhomescreen.moc"
