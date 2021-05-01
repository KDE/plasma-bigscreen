/*
    SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: MIT
*/

#include "bigscreenplugin.h"

#include <QtQml>

void BigScreenPlugin::registerTypes(const char *uri)
{
    Q_ASSERT(uri == QLatin1String("org.kde.mycroft.bigscreen"));

    qmlRegisterSingletonType(componentUrl(QStringLiteral("NavigationSoundEffects.qml")), uri, 1, 0, "NavigationSoundEffects");
}

QUrl BigScreenPlugin::componentUrl(const QString &fileName)
{
    auto url = baseUrl();
    url.setPath(url.path() % QLatin1Char('/'));
    return url.resolved(QUrl{fileName});
}
