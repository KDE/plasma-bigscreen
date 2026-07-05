// SPDX-FileCopyrightText: 2019 Jonah Brüchert <jbb.prv@gmx.de>
// SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

#include <QApplication>
#include <QCommandLineOption>
#include <QCommandLineParser>
#include <QCryptographicHash>
#include <QIcon>
#include <QQmlApplicationEngine>
#include <QQuickWindow>
#include <QUrl>
#include <QtQml>
#include <QtWebEngineQuick>

#include <KAboutData>
#include <KDBusService>
#include <KLocalizedContext>
#include <KLocalizedQmlContext>
#include <KLocalizedString>

#include "browsermanager.h"
#include "useragent.h"

QString webAppIdFromName(const QString &name)
{
    QString filename = name.toLower();
    filename.replace(QChar(u' '), QChar(u'_'));
    filename.remove(u'/');
    filename.remove(u'"');
    filename.remove(u'\'');
    filename.remove(u',');
    filename.remove(u'.');
    filename.remove(u'|');
    return u"bigscreen-webapp-" + filename;
}

int main(int argc, char *argv[])
{
    QGuiApplication::setAttribute(Qt::AA_ShareOpenGLContexts);

    KLocalizedString::setApplicationDomain("plasma-bigscreen");

    // Setup QtWebEngine
    qputenv("QTWEBENGINE_DIALOG_SET", "QtQuickControls2");
    QtWebEngineQuick::initialize();

    QApplication app(argc, argv);
    QCoreApplication::setOrganizationDomain(QStringLiteral("kde.org"));

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
    const QString name = parser.value(nameOption);
    const QString userAgent = parser.value(agentOption);
    const QString appId = webAppIdFromName(name);

    KAboutData aboutData(QStringLiteral("plasma-bigscreen-webapp"),
                         parser.isSet(nameOption) ? name : i18n("Webview"),
                         QStringLiteral("0.1"),
                         i18n("Plasma Bigscreen Webapp runtime"),
                         KAboutLicense::GPL,
                         i18n("© 2025 Plasma developers"));
    QApplication::setWindowIcon(QIcon::fromTheme(QStringLiteral()));

    KAboutData::setApplicationData(aboutData);
    QCoreApplication::setOrganizationDomain(QStringLiteral("kde.org"));
    QCoreApplication::setApplicationName(appId);
    QGuiApplication::setDesktopFileName(appId);

    BrowserManager::instance()->setInitialUrl(initialUrl);
    KDBusService service(KDBusService::Unique, &app);

    // QML loading
    QQmlApplicationEngine engine;

    engine.setInitialProperties({{QStringLiteral("userAgent"), parser.isSet(agentOption) ? userAgent : QString{}}});
    engine.rootContext()->setContextObject(new KLocalizedContext(&engine));
    engine.loadFromModule(QStringLiteral("org.kde.bigscreen.webapp.sources"), QStringLiteral("WebApp"));

    // Error handling
    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    QQuickWindow *mainWindow = qobject_cast<QQuickWindow *>(engine.rootObjects().constFirst());
    Q_ASSERT(mainWindow);

    QObject::connect(&service, &KDBusService::activateRequested, &app, [mainWindow](const QStringList & /*arguments*/, const QString & /*workingDirectory*/) {
        mainWindow->requestActivate();
    });

    return app.exec();
}
