// SPDX-FileCopyrightText: 2019 Jonah Brüchert <jbb.prv@gmx.de>
// SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

#include <QApplication>
#include <QCommandLineOption>
#include <QCommandLineParser>
#include <QIcon>
#include <QQmlApplicationEngine>
#include <QUrl>
#include <QtQml>
#include <QtWebEngineQuick>

#include <KAboutData>
#include <KLocalizedContext>
#include <KLocalizedQmlContext>
#include <KLocalizedString>

#include "browsermanager.h"
#include "useragent.h"

constexpr auto APPLICATION_ID = "org.kde.angelfish";

int main(int argc, char *argv[])
{
    QGuiApplication::setAttribute(Qt::AA_ShareOpenGLContexts);

    KLocalizedString::setApplicationDomain("plasma-bigscreen");

    // Setup QtWebEngine
    qputenv("QTWEBENGINE_DIALOG_SET", "QtQuickControls2");
    QtWebEngineQuick::initialize();

    QApplication app(argc, argv);

    // Command line parser
    QCommandLineOption agentOption{QStringLiteral("agent"),
                                   i18n("The user agent to browse with."),
                                   QStringLiteral("Mozilla/5.0 (Linux; Android 12) Cobalt/22.2.3-gold (PS4)")};
    QCommandLineOption nameOption{QStringLiteral("name"), i18n("The name of the web app"), QStringLiteral("webapp")};

    QCommandLineParser parser;
    parser.addPositionalArgument(QStringLiteral("link"), i18n("link of website to launch"), QStringLiteral("[link]"));
    parser.addOption(agentOption);
    parser.addOption(nameOption);
    parser.addHelpOption();
    parser.process(app);

    if (parser.positionalArguments().isEmpty()) {
        return 1;
    }

    const QString link = parser.positionalArguments().constFirst();
    const QUrl initialUrl = QUrl::fromUserInput(link);

    KAboutData aboutData(QStringLiteral("plasma-bigscreen-webapp"),
                         parser.isSet(nameOption) ? parser.value(nameOption) : i18n("Webview"),
                         QStringLiteral("0.1"),
                         i18n("Plasma Bigscreen Webapp runtime"),
                         KAboutLicense::GPL,
                         i18n("Copyright 2025 Plasma developers"));
    QApplication::setWindowIcon(QIcon::fromTheme(QStringLiteral()));

    KAboutData::setApplicationData(aboutData);

    BrowserManager::instance()->setInitialUrl(initialUrl);

    // QML loading
    QQmlApplicationEngine engine;

    engine.setInitialProperties({{QStringLiteral("userAgent"), parser.isSet(agentOption) ? parser.value(agentOption) : QString{}}});
    engine.rootContext()->setContextObject(new KLocalizedContext(&engine));
    engine.loadFromModule(QStringLiteral("org.kde.bigscreen.webapp.sources"), QStringLiteral("WebApp"));

    // Error handling
    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    return app.exec();
}
