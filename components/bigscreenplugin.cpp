/*
    SPDX-FileCopyrightText: 2021 Aditya Mehra <aix.m@outlook.com>
    SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: MIT
*/

#include "bigscreenplugin.h"
#include "envreader.h"

#include <QtQml>
#include <QQmlEngine>

static QObject *envReaderSingletonProvider(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)

    return new EnvReader;
}

void BigScreenPlugin::registerTypes(const char *uri)
{
    Q_ASSERT(uri == QLatin1String("org.kde.mycroft.bigscreen"));

    qmlRegisterSingletonType(componentUrl(QStringLiteral("NavigationSoundEffects.qml")), uri, 1, 0, "NavigationSoundEffects");
    qmlRegisterSingletonType<EnvReader>(uri, 1, 0, "EnvReader", envReaderSingletonProvider);
}

QUrl BigScreenPlugin::componentUrl(const QString &fileName)
{
    auto url = baseUrl();
    url.setPath(url.path() % QLatin1Char('/'));
    return url.resolved(QUrl{fileName});
}
