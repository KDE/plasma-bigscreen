/*
    SPDX-FileCopyrightText: 2021 Aditya Mehra <aix.m@outlook.com>
    SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: MIT
*/

#include "bigscreenplugin.h"
#include "envreader.h"
#include "global.h"

#include <QQmlEngine>

static QObject *envReaderSingletonProvider(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)

    return new EnvReader;
}

static QObject *globalSingletonProvider(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)

    return new Global;
}



void BigScreenPlugin::registerTypes(const char *uri)
{
    Q_ASSERT(uri == QLatin1String("org.kde.bigscreen"));

    qmlRegisterSingletonType(componentUrl(QStringLiteral("NavigationSoundEffects.qml")), uri, 1, 0, "NavigationSoundEffects");
    qmlRegisterSingletonType<EnvReader>(uri, 1, 0, "EnvReader", envReaderSingletonProvider);
    qmlRegisterSingletonType<Global>(uri, 1, 0, "Global", globalSingletonProvider);
}

QUrl BigScreenPlugin::componentUrl(const QString &fileName)
{
    auto url = baseUrl();
    url.setPath(url.path() % QLatin1Char('/'));
    return url.resolved(QUrl{fileName});
}
