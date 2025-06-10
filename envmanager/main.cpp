// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

#include <QCommandLineParser>
#include <QCoreApplication>
#include <QIcon>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QString>

#include <KAboutData>
#include <KLocalizedString>

#include "settings.h"

using namespace Qt::Literals::StringLiterals;

QCommandLineParser *createParser()
{
    QCommandLineParser *parser = new QCommandLineParser;
    parser->addOption(QCommandLineOption(u"apply-settings"_s, u"Applies the correct system settings for the current environment."_s));
    parser->addVersionOption();
    parser->addHelpOption();
    return parser;
}

int main(int argc, char *argv[])
{
    QCoreApplication app(argc, argv);

    // parse command
    QScopedPointer<QCommandLineParser> parser{createParser()};
    parser->process(app);

    // start wizard
    KLocalizedString::setApplicationDomain("plasma-bigscreen-envmanager");
    QCoreApplication::setApplicationName(u"plasma-bigscreen-envmanager"_s);
    QCoreApplication::setOrganizationDomain(u"kde.org"_s);

    // apply configuration
    if (parser->isSet(u"apply-settings"_s)) {
        Settings::self().applyConfiguration();
    } else {
        parser->showHelp();
    }

    return 0;
}
