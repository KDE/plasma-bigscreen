/*
    SPDX-FileCopyrightText: 2025 Seshan Ravikumar <seshan@sineware.ca>
    SPDX-License-Identifier: LicenseRef-KDE-Accepted-GPL
*/

#include <KIconTheme>
#include <KLocalizedContext>
#include <KLocalizedString>
#include <QApplication>
#include <QQmlApplicationEngine>
#include <QUrl>
#include <QtQml>

int main(int argc, char *argv[])
{
    KIconTheme::initTheme();
    QApplication app(argc, argv);
    KLocalizedString::setApplicationDomain("plasma-bigscreen");
    QApplication::setOrganizationName(QStringLiteral("KDE"));
    QApplication::setOrganizationDomain(QStringLiteral("kde.org"));
    QApplication::setApplicationName(QStringLiteral("Plasma Bigscreen UVC Viewer"));
    QApplication::setDesktopFileName(QStringLiteral("org.kde.plasma.bigscreen.uvcviewer"));

    QApplication::setStyle(QStringLiteral("breeze"));

    QQmlApplicationEngine engine;

    engine.rootContext()->setContextObject(new KLocalizedContext(&engine));
    engine.loadFromModule("org.kde.plasma.bigscreen.uvcviewer", "Main");

    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    return app.exec();
}
