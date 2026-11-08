// SPDX-FileCopyrightText: 2026 User8395 <therealuser8395@proton.me>
// SPDX-License-Identifier: GPL-2.0-only

#include <QApplication>
#include <QCommandLineOption>
#include <QCommandLineParser>
#include <QQmlApplicationEngine>
#include <QtQml>

#include <KAboutData>
#include <KLocalizedContext>
#include <KLocalizedString>
#include <qobject.h>
#include <qqmlintegration.h>
#include <qtmetamacros.h>


int main(int argc, char *argv[])
{
    QGuiApplication::setAttribute(Qt::AA_ShareOpenGLContexts);

    KLocalizedString::setApplicationDomain("plasma-bigscreen-linkredirector");

    QApplication app(argc, argv);

    KAboutData aboutData(QStringLiteral("plasma-bigscreen-linkredirector"),
                         i18n("Plasma Bigscreen Link Redirector"),
                         QStringLiteral("0.1"),
                         i18n("Redirect links to QR codes or KDE Connect devices"),
                         KAboutLicense::GPL,
                         i18n("© 2026 Plasma developers"));
    aboutData.setDesktopFileName(QStringLiteral("org.kde.plasma.bigscreen.linkredirector"));

    QCommandLineParser parser;
    parser.addPositionalArgument("url", "The URL to redirect");
    parser.process(app);
    aboutData.setupCommandLine(&parser);

    QString url = parser.positionalArguments().value(0);

    if (url.isEmpty()) {
        qFatal() << "No URL provided, exiting";
        app.exit();
    }

    KAboutData::setApplicationData(aboutData);

    QQmlApplicationEngine engine;

    engine.rootContext()->setContextObject(new KLocalizedContext(&engine));
    engine.setInitialProperties({
        { "url", url }
    });
    engine.loadFromModule(QStringLiteral("org.kde.plasma.bigscreen.linkredirector"), QStringLiteral("Main"));

    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    return app.exec();
}