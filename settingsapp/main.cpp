// SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

#include <QApplication>
#include <QCommandLineOption>
#include <QCommandLineParser>
#include <QIcon>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickWindow>
#include <QUrl>

#include <KAboutData>
#include <KDBusService>
#include <KLocalizedContext>
#include <KLocalizedQmlContext>
#include <KLocalizedString>
#include <KWindowSystem>

#include "settingsapp.h"

int main(int argc, char *argv[])
{
    qputenv("PLASMA_PLATFORM", QByteArray("mediacenter"));
    qputenv("QT_QUICK_CONTROLS_STYLE", QByteArray("org.kde.breeze"));

    QGuiApplication::setAttribute(Qt::AA_ShareOpenGLContexts);

    KLocalizedString::setApplicationDomain("plasma-bigscreen-settings");

    QApplication app(argc, argv);

    KAboutData aboutData(QStringLiteral("plasma-bigscreen-webapp"),
                         i18n("Bigscreen Settings"),
                         QStringLiteral("0.1"),
                         i18n("Plasma Bigscreen Settings"),
                         KAboutLicense::GPL,
                         i18n("Copyright 2025 Plasma developers"));

    QCommandLineOption moduleOption{QStringLiteral("m"), QStringLiteral("module"), i18n("Settings module to open"), QString()};
    QCommandLineParser parser;
    parser.addOption(moduleOption);
    parser.addHelpOption();
    parser.process(app);
    aboutData.setupCommandLine(&parser);

    KAboutData::setApplicationData(aboutData);

    KDBusService *service = new KDBusService(KDBusService::Unique, &app);

    // QML loading
    QQmlApplicationEngine engine;
    KLocalization::setupLocalizedContext(&engine);

    auto settingsApp = engine.singletonInstance<SettingsApp *>("org.kde.plasma.bigscreen.settings", "SettingsApp");
    settingsApp->setLaunchModule(parser.value(moduleOption));
    engine.rootContext()->setContextObject(new KLocalizedContext(&engine));
    engine.loadFromModule(QStringLiteral("org.kde.plasma.bigscreen.settings"), QStringLiteral("Main"));

    // Error handling
    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    QQuickWindow *mainWindow = qobject_cast<QQuickWindow *>(engine.rootObjects().first());
    Q_ASSERT(mainWindow);

    QObject::connect(service, &KDBusService::activateRequested, &app, [mainWindow](const QStringList & /*arguments*/, const QString & /*workingDirectory*/) {
        // HACK: raise window when module is requested;
        // requestActivate() by itself doesn't seem to work
        mainWindow->hide();
        mainWindow->show();
        mainWindow->requestActivate();
        KWindowSystem::activateWindow(mainWindow);
    });

    return app.exec();
}
