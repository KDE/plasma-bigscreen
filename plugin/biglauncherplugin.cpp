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

#include "biglauncherplugin.h"
#include "biglauncher_dbus.h"
#include "notify.h"
#include "applicationlistmodel.h"
#include "voiceapplistmodel.h"
#include <QtQml>
#include <QtDebug>
#include <QtDBus>

static QObject *notify_singleton(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)

    return new Notify;
}

void BigLauncherPlugin::registerTypes(const char *uri)
{
    Q_ASSERT(uri == QLatin1String("org.kde.private.biglauncher"));
    qmlRegisterSingletonType<Notify>(uri, 1, 0, "Notify", notify_singleton);
    qmlRegisterType<ApplicationListModel>(uri, 1, 0, "ApplicationListModel");
    qmlRegisterType<VoiceAppListModel>(uri, 1, 0, "VoiceAppListModel");
}

void BigLauncherPlugin::initializeEngine(QQmlEngine* engine, const char* uri)
{
  QQmlExtensionPlugin::initializeEngine(engine, uri);
  auto bigLauncherDbusAdapterInterface = new BigLauncherDbusAdapterInterface(engine);
  m_applicationListModel = new ApplicationListModel(this);
  m_voiceAppListModel = new VoiceAppListModel(this);
  engine->rootContext()->setContextProperty("main2", bigLauncherDbusAdapterInterface);
}

ApplicationListModel *BigLauncherPlugin::applicationListModel()
{
    return m_applicationListModel;
}

VoiceAppListModel *BigLauncherPlugin::voiceAppListModel()
{
    return m_voiceAppListModel;
}
